import json
import boto3
from datetime import datetime
from configparser import ConfigParser
from kafka import KafkaConsumer
import pandas as pd
import pyarrow as pa

# kafka server configuration.
config = ConfigParser()
config.read("secrets.ini")

BOOTSTRAP_SERVERS = config["kafka"]["bootstrap_servers"]
TOPIC_NAME = config["kafka"]["topic_name"]
S3_BUCKET = config["aws_s3"]["bucket"]
BATCH_SIZE = 100                        # Max number of events
BATCH_DATA_SIZE = 100 * 1024 * 1024   # Max allowed file size 100MB
data = []
data_size_in_bytes = 0

# Kafka consumer configuration
print('Reading data from kafka topic...')
consumer = KafkaConsumer(
    TOPIC_NAME,
    bootstrap_servers=BOOTSTRAP_SERVERS,
    auto_offset_reset='earliest',
    enable_auto_commit=True,
    value_deserializer=lambda x: json.loads(x.decode('utf-8'))
)

# S3 client configuration
s3 = boto3.client('s3')
bucket_name = S3_BUCKET

# Consume messages from Kafka
print('Processing data.')
for message in consumer:
    event_data = message.value
    partition_key = message.partition
    processed_time_in_ms = (datetime.now() - datetime(1970, 1, 1)).total_seconds()
    data.append({**event_data, 'partition_key' : partition_key, 'processed_time' : processed_time_in_ms})

    data_size_in_bytes += len(json.dumps(event_data).encode('utf-8'))
    
    if len(data) >= BATCH_SIZE or  data_size_in_bytes >= BATCH_DATA_SIZE:
        print('Converting data in parquet')
        
        # special care needed with log_params for now we will skip that column
        df = pd.DataFrame(data)
        
        df['id'] = df['id'].astype('double')  #convert to string to avoid issues

        if 'log_params' in df.columns:
            df = df.drop('log_params', axis=1)

        parquet_data = df.to_parquet()
        
        print('Upload data into s3  ')
        # s3 prefix inside bucket topic_name/year/month/day/data_[upload_time_in_ms].parquet
        s3_prefix = f"{TOPIC_NAME}/{datetime.now().year}/{datetime.now().month}/{datetime.now().day}/data_{(datetime.now() - datetime(1970, 1, 1)).total_seconds()}.parquet"

        s3.put_object(
            Body=parquet_data,
            Bucket=bucket_name,
            Key=s3_prefix
        )

        print(f"Stored a total of - {len(data)} events. Batch size {data_size_in_bytes} in s3://{bucket_name}/{s3_prefix}")

        #Reset variables for next batch
        data = []
        data_size_in_bytes

    
