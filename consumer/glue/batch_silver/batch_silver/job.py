"""Glue Batch Silver Job.

This module contains the Glue Batch Silver Job, which is responsible for
processing the raw data from the Bronze layer and writing it to the Silver
layer in the Data Lakehouse.

The mandatory steps are:
1. Read the arguments passed to the job
2. Read the raw data from the Bronze layer
3. Apply basic transformation operations
4. Load the resulting data into a Delta table in the Silver layer

The mandatory job parameters are:
--conf: The Spark configuration
--input_folder: The folder where the raw data is stored
--output_table: The name of the Delta table to create
--s3_datalake_bucket: The S3 bucket where the Data Lakehouse is stored

"""

import sys

from awsglue.context import GlueContext
from awsglue.job import Job
from awsglue.utils import getResolvedOptions
from pyspark.context import SparkContext
from pyspark.sql.functions import col

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


def create_silver_table():
    """Create the Silver table in the Data Lakehouse.

    This function creates Delta table in the Silver layer of the Data Lakehouse
    to store the processed data from the Bronze layer.

    Using the Spark SQL API, the function creates a new Delta table in the
    `datalakehouse` database with the specified schema.
    """
    for table in ["sales", "purchases"]:
        final_table_name = f"{TABLE_NAME}_{table}"
        silver_table = f"""
            CREATE TABLE IF NOT EXISTS {DATABASE}.{final_table_name} (
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
            LOCATION '{DELTA_S3_PATH + final_table_name}/'
        """
        spark.sql(silver_table)


def main():
    """Glue Batch Silver Job."""
    # Log the start of the job
    logger.info("Initializing Glue job.")

    create_silver_table()

    # Read the raw data from the Bronze layer
    df = glue_context.create_data_frame.from_catalog(
        database=INPUT_DATABASE, table_name=INPUT_TABLE
    )

    # Apply basic transformation operations
    df = df.withColumn("price", col("price").cast("double"))

    sales_df = df.filter(col("operation") == "sale")
    purchases_df = df.filter(col("operation") == "purchase")

    # Load the resulting data into a Delta table in the Silver layer
    # sales_df.write.format("delta").mode("append").partitionBy(PARTITION_KEY).saveAsTable(  # noqa: E501
    #     f"{DATABASE}.{TABLE_NAME}_sales"
    # )
    #
    # purchases_df.write.format("delta").mode("append").partitionBy(PARTITION_KEY).saveAsTable(  # noqa: E501
    #     f"{DATABASE}.{TABLE_NAME}_purchases"
    # )

    glue_context.write_data_frame.from_catalog(
        frame=sales_df, database=DATABASE, table_name=f"{TABLE_NAME}_sales"
    )

    glue_context.write_data_frame.from_catalog(
        frame=purchases_df,
        database=DATABASE,
        table_name=f"{TABLE_NAME}_purchases",
    )

    # Commit the job
    job.commit()

    # Log the end of the job
    logger.info("Glue job completed.")


if __name__ == "__main__":
    main()
