resource "aws_s3_bucket" "lakehouse_bucket" {
  bucket = "lakehouse-bucket-${var.environment}-${data.aws_caller_identity.current.account_id}"

  force_destroy = true
}

resource "aws_s3_bucket" "resources_bucket" {
  bucket = "resources-bucket-${var.environment}-${data.aws_caller_identity.current.account_id}"

  force_destroy = true
}

resource "aws_s3_object" "streaming_job" {
  bucket = aws_s3_bucket.resources_bucket.bucket
  key    = "delta/ingest_data/streaming_job.py"
  source = "${var.project_root}/consumer/glue/streaming_consumer/streaming_consumer/job.py"
}

resource "aws_s3_object" "silver_job" {
  bucket = aws_s3_bucket.resources_bucket.bucket
  key    = "delta/ingest_data/silver_job.py"
  source = "${var.project_root}/consumer/glue/batch_silver/batch_silver/job.py"
}

resource "aws_s3_object" "gold_job" {
  bucket = aws_s3_bucket.resources_bucket.bucket
  key    = "delta/ingest_data/gold_job.py"
  source = "${var.project_root}/consumer/glue/batch_gold/batch_gold/job.py"
}
