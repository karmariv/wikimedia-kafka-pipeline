from configparser import ConfigParser
from kafka import KafkaProducer
#import requests
import json
from sseclient import SSEClient as EventSource

# Constants
WIKIMEDIA_CHANGES_URL = 'https://stream.wikimedia.org/v2/stream/recentchange'

# kafka server configuration.
config = ConfigParser()
config.read("secrets.ini")

BOOTSTRAP_SERVERS = config["kafka"]["bootstrap_servers"]
TOPIC_NAME = config["kafka"]["topic_name"]

# Kafka Producer instance
producer = KafkaProducer(bootstrap_servers=BOOTSTRAP_SERVERS)

# Create kafka producer instance
#while True:
#    try:
#        response = requests.get(WIKIMEDIA_URL, stream=True)
#        if response.status_code == 200:
#            for line in response.iter_lines():
#                if line.decode('utf-8').startswith('data:'):
#                    line = line.decode('utf-8').replace('data: ', '')
#                    try:
#                        data = json.loads(line)
#                        producer.send('demo_testing2', json.dumps(data).encode('utf-8'))
#                        print(f"Sent data to Kafka topic: {TOPIC_NAME}")
#                    except json.JSONDecodeError as e:
#                        print("Skipping non-JSON line: " + json.loads(line.decode('utf-8')[2:]))

#        else:
#            print(f"Error: {response.status_code}")                     
#    except Exception as e:
#         print(f"Response Error: {e}")

for event in EventSource(WIKIMEDIA_CHANGES_URL, last_id=None):
    if event.event == 'message':
        try:
            data = json.loads(event.data)

            #send data to kafka, but discard canary events
            if data['meta']['domain'] != 'canary':
                producer.send(TOPIC_NAME, json.dumps(data).encode('utf-8'))
                print(data)
                #print(data['type'])
                print(f"Sent data to Kafka topic: {TOPIC_NAME}", data['type'])
            
        except ValueError:
            pass
        
    

    





    

