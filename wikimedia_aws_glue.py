import sys
from awsglue.transforms import *
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.dynamicframe import DynamicFrame

## @params: [JOB_NAME]
args = getResolvedOptions(sys.argv, ['JOB_NAME'])

sc = SparkContext()
glueContext = GlueContext(sc)
spark = glueContext.spark_session
job = Job(glueContext)
job.init(args['JOB_NAME'], args)

data_source = glue_context.create_dynamic_frame.from_catalog(
    database="wikimedia",
    table_name="wikimedia_recent_changes",
    transformation_ctx="datasource0"
)

# Read data from S3 bucket
# Set the input and output paths
input_path = "s3://demo-kr/wikimedia_recent_changes/" #"s3://your-bucket/wikimedia/changes/"
output_path = "s3://demo-kr/wikimedia_glue_output/"  #"s3://your-bucket/wikimedia/changes/output/"

# Read the Parquet files recursively
df = spark.read.parquet(input_path)
df = data_source.toDF()

# Count events by type and group the data
grouped_df = df.groupBy("type").count()

# Write the output to S3
grouped_df.write.mode("overwrite").parquet(output_path)

job.commit()
