module "vpc" {
  source = "./modules/vpc"

  vpc_cidr            = var.vpc_cidr
  project_name        = var.project_name
  environment         = var.environment
  tags                = local.vpc_tags
}

module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.iam_tags
}

module "org_scp" {
  source = "./modules/org_scp"

  org_master_account_id = var.org_master_account_id
  tags                  = local.iam_tags
}

module "logging" {
  source = "./modules/logging"

  project_name  = var.project_name
  environment   = var.environment
  vpc_id        = module.vpc.vpc_id
  flow_log_role = module.iam.vpc_flow_logs_role_arn
  tags          = local.logging_tags
}

module "monitoring" {
  source = "./modules/monitoring"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.monitoring_tags
}

module "connectivity" {
  source = "./modules/connectivity"

  project_name       = var.project_name
  environment        = var.environment
  vpc_id             = module.vpc.vpc_id
  private_subnet_ids = module.vpc.private_subnet_ids
  tags               = local.vpc_tags
}

module "eks_litellm" {
  source = "./modules/eks_litellm"

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.vpc.vpc_id
  private_subnet_ids     = module.vpc.private_subnet_ids
  eks_version            = var.eks_version
  eks_node_instance_type = var.eks_node_instance_type
  eks_node_min_size      = var.eks_node_min_size
  eks_node_max_size      = var.eks_node_max_size
  tags                   = local.litellm_tags
}

module "service_catalog" {
  source = "./modules/service_catalog"

  project_name = var.project_name
  environment  = var.environment
  tags         = local.base_tags
}
