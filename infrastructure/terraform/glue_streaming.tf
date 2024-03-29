resource "aws_glue_job" "streaming_job" {
  name              = "delta streaming job"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  number_of_workers = 2
  worker_type       = "G.1X"


  command {
    name            = "gluestreaming"
    script_location = "s3://${aws_s3_bucket.resources_bucket.id}/${aws_s3_object.streaming_job.key}"
  }

  default_arguments = {
    "--conf"                    = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore"
    "--datalake-formats"        = "delta"
    "--enable-glue-datacatalog" = "true"
    "--kinesis_arn"             = aws_kinesis_stream.stream.arn
    "--catalog"                 = "spark_catalog"
    "--database_name"           = aws_glue_catalog_database.glue_catalog_database_bronze.name
    "--table_name"              = "financial_transactions"
    "--primary_key"             = "operation_id"
    "--partition_key"           = "exchange"
    "--delta_s3_path"           = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/bronze/financial_transactions/"
    "--window_size"             = "100 seconds"
    "--checkpoint_path"         = "s3://${aws_s3_bucket.lakehouse_bucket.id}/checkpoint/financial_transactions/"
  }
}
