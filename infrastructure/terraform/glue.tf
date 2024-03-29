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

# Create Glue Catalog Database
resource "aws_glue_catalog_database" "glue_catalog_database_bronze" {
  name         = "${var.lakehouse_name}_bronze"
  location_uri = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/bronze/"
}

resource "aws_glue_catalog_database" "glue_catalog_database_silver" {
  name         = "${var.lakehouse_name}_silver"
  location_uri = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/silver/"
}

resource "aws_glue_catalog_database" "glue_catalog_database_gold" {
  name         = "${var.lakehouse_name}_gold"
  location_uri = "s3://${aws_s3_bucket.lakehouse_bucket.id}/delta/financial_transactions/gold/"
}
