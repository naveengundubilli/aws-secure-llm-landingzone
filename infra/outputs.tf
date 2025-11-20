output "vpc_id" {
  value = module.vpc.vpc_id
}

output "private_subnet_ids" {
  value = module.vpc.private_subnet_ids
}

output "eks_cluster_name" {
  value = module.eks_litellm.cluster_name
}

output "eks_litellm_service_dns_hint" {
  value = module.eks_litellm.service_name
}

output "cloudtrail_bucket" {
  value = module.logging.cloudtrail_bucket_id
}
