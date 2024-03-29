"""Glue Streaming Consumer.

This module contains the code to consume the data
from the Kinesis stream and write it to the Iceberg table.

The mandatory steps are:
1. Read the arguments passed to the job
2. Read the streaming data from the Kinesis stream
3. Write the streaming data to the Iceberg table

The mandatory job parameters are:
--conf: The Spark configuration
"""
import sys

from awsglue import DynamicFrame
from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.conf import SparkConf
from pyspark.context import SparkContext
from pyspark.sql import Window
from pyspark.sql.functions import col, desc, row_number, to_timestamp

# Import the libraries

conf = SparkConf()
sc = SparkContext.getOrCreate()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
logger = glue_context.get_logger()
job = Job(glue_context)

logger.info("Starting Glue job: job.py")
logger.info("Reading the arguments passed to the job")
# Read the arguments passed to the job
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "catalog",
        "database_name",
        "table_name",
        "primary_key",
        "partition_key",
        "kinesis_arn",
        "delta_s3_path",
        "window_size",
        "checkpoint_path",
    ],
)

# Get the arguments
JOB_NAME = args["JOB_NAME"].strip()
CATALOG = args["catalog"].strip()
DATABASE = args["database_name"].strip()
TABLE_NAME = args["table_name"].strip()
PRIMARY_KEY = args["primary_key"].strip()
PARTITION_KEY = args["partition_key"].strip()
KINESIS_ARN = args["kinesis_arn"].strip()
DELTA_S3_PATH = args["delta_s3_path"].strip()
WINDOW_SIZE = args["window_size"].strip()
CHECKPOINT_PATH = args["checkpoint_path"].strip()

# Initialize the job
job.init(JOB_NAME, args)

logger.info(
    f"Glue Job parameters:\n"
    f"JOB_NAME: {JOB_NAME}\n"
    f"CATALOG: {CATALOG}\n"
    f"DATABASE: {DATABASE}\n"
    f"TABLE_NAME: {TABLE_NAME}\n"
    f"PRIMARY_KEY: {PRIMARY_KEY}\n"
    f"PARTITION_KEY: {PARTITION_KEY}\n"
    f"KINESIS_ARN: {KINESIS_ARN}\n"
    f"DELTA_S3_PATH: {DELTA_S3_PATH}\n"
    f"WINDOW_SIZE: {WINDOW_SIZE}\n"
    f"OUTPUT_PATH: {CHECKPOINT_PATH}"
)


def process_batch(mini_batch_df, batch_id):
    """Process the mini batch DataFrame.

    Args:
    ----
        mini_batch_df: The mini batch DataFrame
        batch_id: The batch ID

    Returns:
    -------
        None

    """
    logger.info(f"Processing batch: {batch_id}")
    create_delta_lake = f"""
        CREATE TABLE IF NOT EXISTS {DATABASE}.{TABLE_NAME} (
            operation_id STRING,
            person_name STRING,
            symbol STRING,
            timestamp TIMESTAMP,
            exchange STRING,
            currency STRING,
            price DOUBLE,
            operation STRING
        ) USING DELTA
        PARTITIONED BY ({PARTITION_KEY})
        LOCATION '{DELTA_S3_PATH}'
    """

    spark.sql(create_delta_lake)

    if mini_batch_df.count() > 0:
        stream_df = DynamicFrame.fromDF(
            mini_batch_df, glue_context, "stream_df"
        )
        _df = spark.sql(
            f"SELECT * FROM {CATALOG}.{DATABASE}.{TABLE_NAME} LIMIT 0"
        )
        # Apply De-duplication logic on input data to pick up the latest record based on timestamp and operation # noqa: E501
        window = Window.partitionBy(PRIMARY_KEY).orderBy(desc("timestamp"))
        stream_data_df = stream_df.toDF()
        stream_data_df = stream_data_df.withColumn(
            "timestamp", to_timestamp(col("timestamp"), "yyyy-MM-dd HH:mm:ss")
        )
        upsert_data_df = (
            stream_data_df.withColumn("row", row_number().over(window))
            .filter(col("row") == 1)
            .drop("row")
            .select(_df.schema.names)
        )

        upsert_data_df.createOrReplaceTempView(f"{TABLE_NAME}_temp")
        sql_query = f"""
            MERGE INTO {CATALOG}.{DATABASE}.{TABLE_NAME} AS target
            USING {TABLE_NAME}_temp AS source
            ON target.{PRIMARY_KEY} = source.{PRIMARY_KEY}
            WHEN MATCHED THEN
                UPDATE SET *
            WHEN NOT MATCHED THEN
                INSERT *
        """
        try:
            spark.sql(sql_query)
        except Exception as e:
            logger.error(f"Error while processing the batch: {e}")
            raise e


# Read the streaming data from the Kinesis stream
logger.info("Reading the streaming data from the Kinesis stream")
kinesis_options = {
    "typeOfData": "kinesis",
    "streamARN": KINESIS_ARN,
    "startingPosition": "LATEST",
    "inferSchema": "true",
    "classification": "json",
}
df = glue_context.create_data_frame.from_options(
    connection_type="kinesis", connection_options=kinesis_options
)

df.printSchema()

# Write the streaming data to the Iceberg table
logger.info("Writing the streaming data to the Iceberg table")
# checkpoint_path = f"{OUTPUT_PATH}/checkpoint"
glue_context.forEachBatch(
    frame=df,
    batch_function=process_batch,
    options={
        "checkpointLocation": CHECKPOINT_PATH,
        "windowSize": WINDOW_SIZE,
    },
)
job.commit()
