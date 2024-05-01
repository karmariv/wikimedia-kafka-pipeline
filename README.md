## Wikimedia Streaming Data Pipeline

he Pipeline: The pipeline starts by pulling data from the Wikipedia recent changes stream (https://stream.wikimedia.org/v2/stream/recentchange). This stream provides a real-time feed of edits made to Wikipedia articles across various language editions.

Kafka Producer and Consumer:

An EC2 instance is provisioned with Apache Kafka installed.
A Kafka topic is created to serve as the central hub for streaming data.
A Python-based Kafka producer script is responsible for fetching data from the Wikipedia stream and pushing it to the Kafka topic.
A Kafka consumer script reads data from the topic and stores it as Parquet files in an S3 bucket.
Data Storage and Processing:

The Parquet files in the S3 bucket serve as the landing zone for the ingested data.
AWS Glue Crawler is configured to automatically detect and catalog the data in the S3 bucket.
An AWS Glue job is triggered to perform additional processing on the ingested data.
In this example, the Glue job counts the number of events by change type and stores the aggregated results back in S3.
Infrastructure as Code with Terraform:

Terraform scripts are provided to streamline the provisioning and management of the required AWS resources.
These scripts automate the creation of resources such as EC2 instances, Kafka clusters, S3 buckets, Glue Crawlers, and Glue jobs.
Getting Started: To set up and run this pipeline, follow these steps:

Deploy the infrastructure using the provided Terraform scripts.
Create a Kafka topic and update the secrets.ini file with the topic name.
Run the Kafka producer script to start ingesting data from the Wikipedia stream.
Run the Kafka consumer script to store the ingested data as Parquet files in the designated S3 bucket.
Optionally, trigger the AWS Glue Crawler and Glue job to perform additional processing on the ingested data.
Benefits and Use Cases: This streaming data pipeline demonstrates the power of AWS services in building scalable and robust data ingestion and processing solutions. Some potential use cases include:

Real-time monitoring and analysis of Wikipedia edits for various purposes, such as content moderation, trend detection, or research.
Ingesting and processing other types of streaming data sources, such as IoT sensor data, social media feeds, or financial market data.
Building data lakes or data warehouses for batch or real-time analytics.
Integrating with other AWS services like Kinesis, Lambda, or Athena for further data processing or querying.
