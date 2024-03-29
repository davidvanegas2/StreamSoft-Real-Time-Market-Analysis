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
