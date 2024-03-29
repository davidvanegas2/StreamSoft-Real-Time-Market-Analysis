resource "aws_iam_role" "glue_role" {
  name = "glue_role_${data.aws_caller_identity.current.account_id}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "glue_service_role_policy" {
  name        = "glue_policy_${data.aws_caller_identity.current.account_id}"
  description = "Policy for Glue Role to access S3 scripts bucket"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          "*" # Replace with your S3 scripts bucket ARN
        ]
      },
      {
        Action = [
          "kinesis:*"
        ]
        Effect   = "Allow"
        Resource = ["*"]
      },
      {
        Action = [
          "glue:*"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      },
      {
        Action = [
          "cloudwatch:*"
        ]
        Effect   = "Allow",
        Resource = ["*"]
      },
      {
        Action = [
          "logs:*"
        ],
        Effect   = "Allow",
        Resource = ["*"]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "glue_role_policy_attachment" {
  role       = aws_iam_role.glue_role.id
  policy_arn = aws_iam_policy.glue_service_role_policy.arn
}

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
    "--conf"                    = "spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.sql.catalog.spark_catalog=org.apache.spark.sql.delta.catalog.DeltaCatalog --conf spark.sql.extensions=io.delta.sql.DeltaSparkSessionExtension --conf spark.delta.logStore.class=org.apache.spark.sql.delta.storage.S3SingleDriverLogStore"
    "--datalake-formats"        = "delta"
    "--catalog"                 = "spark_catalog"
    "--enable-glue-datacatalog" = "true"
    "--database_name"           = var.lakehouse_name
    "--table_name"              = "financial_transactions"
    "--primary_key"             = "operation_id"
    "--partition_key"           = "exchange"
    "--kinesis_arn"             = aws_kinesis_stream.stream.arn
    "--delta_s3_path"           = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/"
    "--window_size"             = "100 seconds"
    "--checkpoint_path"         = "s3://${aws_s3_bucket.lakehouse_bucket.id}/checkpoint/financial_transactions/"
  }
}

resource "aws_glue_catalog_database" "glue_catalog_database" {
  name         = var.lakehouse_name
  location_uri = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/"
}
