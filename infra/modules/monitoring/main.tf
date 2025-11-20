resource "aws_guardduty_detector" "this" {
  enable = true
  tags   = var.tags
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/aws/app/${var.project_name}-${var.environment}"
  retention_in_days = 365
  tags              = var.tags
}
