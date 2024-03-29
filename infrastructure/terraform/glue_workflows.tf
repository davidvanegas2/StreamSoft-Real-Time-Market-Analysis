resource "aws_glue_workflow" "workflow" {
  name = "workflow_${var.lakehouse_name}"
}

resource "aws_glue_trigger" "start_streaming_job_trigger" {
  name = "start_streaming_job_trigger_${var.lakehouse_name}"
  type = "ON_DEMAND"

  actions {
    job_name = aws_glue_job.streaming_job.name
  }
}

resource "aws_glue_trigger" "start_workflow_trigger" {
  name              = "start_workflow_trigger_${var.lakehouse_name}"
  type              = "SCHEDULED"
  schedule          = "cron(0/10 * * * ? *)"
  start_on_creation = false
  workflow_name     = aws_glue_workflow.workflow.name

  actions {
    job_name = aws_glue_job.silver.name
  }
}

resource "aws_glue_trigger" "end_workflow_trigger" {
  name          = "end_workflow_trigger_${var.lakehouse_name}"
  type          = "CONDITIONAL"
  workflow_name = aws_glue_workflow.workflow.name

  predicate {
    conditions {
      job_name = aws_glue_job.silver.name
      state    = "SUCCEEDED"
    }
  }

  actions {
    job_name = aws_glue_job.gold.name
  }
}
