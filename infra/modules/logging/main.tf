resource "aws_s3_bucket" "cloudtrail" {
  bucket = "${var.project_name}-${var.environment}-cloudtrail-logs"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  tags = merge(var.tags, { Name = "${var.project_name}-${var.environment}-cloudtrail-logs" })
}

resource "aws_cloudtrail" "this" {
  name                          = "${var.project_name}-${var.environment}-trail"
  s3_bucket_name                = aws_s3_bucket.cloudtrail.id
  include_global_service_events = true
  is_multi_region_trail         = true
  enable_log_file_validation    = true

  event_selector {
    read_write_type           = "All"
    include_management_events = true
  }

  tags = var.tags
}

resource "aws_cloudwatch_log_group" "vpc_flow" {
  name              = "/aws/vpc/flowlogs/${var.project_name}-${var.environment}"
  retention_in_days = 365
  tags              = var.tags
}

resource "aws_flow_log" "vpc" {
  log_destination_type = "cloud-watch-logs"
  log_group_name       = aws_cloudwatch_log_group.vpc_flow.name
  iam_role_arn         = var.flow_log_role

  traffic_type = "ALL"
  vpc_id       = var.vpc_id

  tags = merge(var.tags, {
    Name = "${var.project_name}-${var.environment}-vpc-flowlogs"
  })
}

output "cloudtrail_bucket_id" {
  value = aws_s3_bucket.cloudtrail.id
}
