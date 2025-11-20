locals {
  base_tags = {
    Project     = var.project_name
    Environment = var.environment
    Owner       = "Platform-Engineering"
    CostCentre  = "CC-LLM-001"
    DataClass   = "Protected"
  }

  vpc_tags        = merge(local.base_tags, { Component = "networking" })
  iam_tags        = merge(local.base_tags, { Component = "iam" })
  logging_tags    = merge(local.base_tags, { Component = "logging" })
  monitoring_tags = merge(local.base_tags, { Component = "monitoring" })
  litellm_tags    = merge(local.base_tags, { Component = "litellm-gateway" })
}
