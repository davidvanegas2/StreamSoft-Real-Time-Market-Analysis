"""Glue Batch Gold Job.

This module contains the Glue Batch Gold Job, which is responsible for
processing the raw data from the Silver layer and writing it to the Gold
layer in the Data Lakehouse.

The mandatory steps are:
1. Read the arguments passed to the job
2. Read the raw data from the Silver layer
3. Apply basic transformation operations
4. Load the resulting data into a Delta table in the Gold layer

"""

import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext

# Create a Spark context
sc = SparkContext()
glue_context = GlueContext(sc)
spark = glue_context.spark_session
job = Job(glue_context)
logger = glue_context.get_logger()

# Log the start of the job
logger.info("Starting Glue job: job.py")
# Read the arguments passed to the job
args = getResolvedOptions(
    sys.argv,
    [
        "JOB_NAME",
        "database_name",
        "table_name",
        "input_table",
        "input_database",
        "partition_key",
        "delta_s3_path",
    ],
)

# Get the arguments
JOB_NAME = args["JOB_NAME"].strip()
DATABASE = args["database_name"].strip()
TABLE_NAME = args["table_name"].strip()
INPUT_TABLE = args["input_table"].strip()
INPUT_DATABASE = args["input_database"].strip()
PARTITION_KEY = args["partition_key"].strip()
DELTA_S3_PATH = args["delta_s3_path"].strip()

# Initialize the job
job.init(JOB_NAME, args)

logger.info(
    f"Glue Job parameters:\n"
    f"Database Name:\t{DATABASE}\n"
    f"Table Name:\t{TABLE_NAME}"
    f"Input Table:\t{INPUT_TABLE}\n"
    f"Input Database:\t{INPUT_DATABASE}\n"
    f"Partition Key:\t{PARTITION_KEY}\n"
    f"Delta S3 Path:\t{DELTA_S3_PATH}"
)


def create_gold_table():
    """Create the Gold table in the Data Lakehouse."""
    for table in ["sales", "purchases"]:
        final_table_name = f"{TABLE_NAME}_{table}"
        gold_table = f"""
            CREATE TABLE IF NOT EXISTS {DATABASE}.{final_table_name} (
                exchange STRING,
                count_operations LONG
            ) USING DELTA
            PARTITIONED BY ({PARTITION_KEY})
            LOCATION '{DELTA_S3_PATH + final_table_name}/'
        """
        spark.sql(gold_table)


def main():
    """Glue batch Gold job."""
    logger.info("Initializing the Glue job")
    # Create the Gold table
    create_gold_table()

    for operation in ["sales", "purchases"]:
        # Read the data from the Silver layer
        df = glue_context.create_data_frame.from_catalog(
            database=INPUT_DATABASE, table_name=f"{INPUT_TABLE}_{operation}"
        )

        # Apply basic transformation operations (Group by exchange)
        df = (
            df.groupBy("exchange")
            .count()
            .withColumnRenamed("count", "count_operations")
        )

        # Write the resulting data to the Gold layer
        df.write.format("delta").mode("overwrite").partitionBy(
            PARTITION_KEY
        ).saveAsTable(f"{DATABASE}.{TABLE_NAME}_{operation}")

        logger.info(f"Data written to {DATABASE}.{TABLE_NAME}_{operation}")

    job.commit()


if __name__ == "__main__":
    main()
