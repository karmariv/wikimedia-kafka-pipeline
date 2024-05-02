## Wikimedia Streaming Data Pipeline
This project builds a pipeline that pulls data from the Wikipedia recent changes stream (https://stream.wikimedia.org/v2/stream/recentchange, This stream provides a real-time feed of edits made to Wikipedia articles across various language editions) using different AWS services.

# Achitecture
- Kafka Producer and Consumer: An EC2 instance is provisioned with Apache Kafka installed. A Kafka topic is created to serve as the central hub for streaming data. A Python-based Kafka producer script (wikimedia_producer.py) is responsible for fetching data from the Wikipedia stream and pushing it to the Kafka topic. And a Kafka consumer script (wikimedia_consumer.py) reads data from the topic and stores it as Parquet files in an S3 bucket.

- Data Storage and Processing:
The Parquet files in the S3 bucket serve as the landing zone for the ingested data. Consumer groups the data in batches of 100 records or 100MB (whatever happens first) before sending it to S3.
AWS Glue Crawler is configured to detect and catalog the data in the S3 bucket. And an AWS Glue job can be triggered to perform additional processing on the ingested data. In this example, the Glue job counts the number of events by change type and stores the aggregated results back in S3.



![wikimedia-kafka-pipeline drawio](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/80e3e7d5-b894-4104-9deb-f978e67652c9)



- Deployment:
Terraform scripts are provided to streamline the provisioning and management of the required AWS resources.These scripts automate the creation of resources such as EC2 instances, Kafka clusters, S3 buckets, Glue Crawlers, and Glue jobs.

# Getting Started
- Clone git repository in your local machine
- Run the terraform script
- Once terraform completes the deployment copy the IP provided, this will be use later to update your Secrets.ini file

![image](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/42d5ef57-e62c-4e0b-8ba7-1b030d0fb4a5)
  
- Next login into the ec2 instance start services and create the topic
  
![image](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/4705e93d-d062-47c7-8963-6d7b24d32064)

Start zookeeper:
```
bin/zookeeper-server-start.sh config/zookeeper.properties
```

Start Kafka:
```
bin/kafka-server-start.sh config/server.properties
```

Create topic
```
bin/kafka-topics.sh --bootstrap-server localhost:9092 --topic wikimedia_changes --create --partitions 1 --replication-factor 1
```

- Configure your secret.ini file. Add the IP address provided in the terraform log and update the topic name

![image](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/858e6176-edf3-4692-931b-3807c0809a84)
  
- Start running the producer and consumer

Producer:
```
python3 wikimedia_producer.py
```

Consumer:
```
python3 wikimedia_consumer.py
```
  
- Once you start getting the data you can run the glue crawler to and glue job to perform additional processing of the ingesting data.

Crawler:
![image](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/2a89ee80-dde5-4802-94c7-cffbe75883a5)

Glue Job:
![image](https://github.com/karmariv/wikimedia-kafka-pipeline/assets/19791050/1710bd59-1a54-4e7b-a915-98275d9c91eb)


  

# Additional Resources
- Wikimedia service documentation => https://wikitech.wikimedia.org/wiki/Event_Platform/EventStreams_HTTP_Service#Python
- API changes documentation => https://www.mediawiki.org/wiki/API:RecentChanges#Python
