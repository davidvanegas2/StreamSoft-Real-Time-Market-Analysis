resource "aws_glue_job" "silver" {
  name              = "silver batch job"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.resources_bucket.id}/${aws_s3_object.silver_job.key}"
  }

  default_arguments = {
    "--conf"                    = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore"
    "--datalake-formats"        = "delta"
    "--enable-glue-datacatalog" = "true"
    "--database_name"           = aws_glue_catalog_database.glue_catalog_database_silver.name
    "--table_name"              = "financial_transactions"
    "--input_table"             = "financial_transactions"
    "--input_database"          = aws_glue_catalog_database.glue_catalog_database_bronze.name
    "--partition_key"           = "exchange"
    "--delta_s3_path"           = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/silver/"
  }
}

resource "aws_glue_job" "gold" {
  name              = "gold batch job"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"

  command {
    name            = "glueetl"
    script_location = "s3://${aws_s3_bucket.resources_bucket.id}/${aws_s3_object.gold_job.key}"
  }

  default_arguments = {
    "--conf"                    = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore"
    "--datalake-formats"        = "delta"
    "--enable-glue-datacatalog" = "true"
    "--database_name"           = aws_glue_catalog_database.glue_catalog_database_gold.name
    "--table_name"              = "financial_transactions"
    "--input_table"             = "financial_transactions"
    "--input_database"          = aws_glue_catalog_database.glue_catalog_database_silver.name
    "--partition_key"           = "exchange"
    "--delta_s3_path"           = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/gold/"
  }
}
