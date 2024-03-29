resource "aws_athena_workgroup" "lakehouse_workgroup" {
  name          = "streaming_workgroup"
  force_destroy = true

  configuration {
    enforce_workgroup_configuration    = true
    publish_cloudwatch_metrics_enabled = true

    result_configuration {
      output_location = "s3://${aws_s3_bucket.resources_bucket.bucket}/athena_results/"
    }
  }
}
