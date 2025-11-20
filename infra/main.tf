resource "aws_servicecatalog_portfolio" "onboarding" {
  name          = "${var.project_name}-${var.environment}-onboarding-portfolio"
  provider_name = "Platform Engineering"
  description   = "Standardised onboarding for LLM workloads."

  tags = var.tags
}

resource "aws_servicecatalog_product" "vpc_baseline" {
  name         = "${var.project_name}-${var.environment}-vpc-baseline"
  owner        = "Platform Engineering"
  product_type = "CLOUD_FORMATION_TEMPLATE"

  provisioning_artifact_parameters {
    name = "v1"
    type = "CLOUD_FORMATION_TEMPLATE"
    info = {
      LoadTemplateFromURL = "https://example.com/vpc-baseline-template.yaml"
    }
  }

  tags = var.tags
}

resource "aws_servicecatalog_portfolio_product_association" "assoc" {
  portfolio_id = aws_servicecatalog_portfolio.onboarding.id
  product_id   = aws_servicecatalog_product.vpc_baseline.id
}
