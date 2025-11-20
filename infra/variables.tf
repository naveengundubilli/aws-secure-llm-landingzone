variable "aws_region" {
  type        = string
  default     = "ap-southeast-2"
  description = "AWS region."
}

variable "project_name" {
  type        = string
  default     = "aws-secure-llm-landingzone"
  description = "Project name used for tagging."
}

variable "environment" {
  type        = string
  description = "Environment name (e.g. dev, prod)."
}

variable "org_master_account_id" {
  type        = string
  description = "AWS Organizations management account ID (for SCPs)."
}

variable "vpc_cidr" {
  type        = string
  default     = "10.10.0.0/16"
  description = "CIDR block for the landing zone VPC."
}

variable "allowed_admin_cidrs" {
  type        = list(string)
  default     = []
  description = "Admin IP ranges allowed for bastion/SSM etc."
}

variable "eks_version" {
  type        = string
  default     = "1.30"
  description = "EKS cluster version."
}

variable "eks_node_instance_type" {
  type        = string
  default     = "t3.medium"
  description = "Instance type for EKS managed node group."
}

variable "eks_node_min_size" {
  type        = number
  default     = 2
  description = "Minimum node count for EKS node group."
}

variable "eks_node_max_size" {
  type        = number
  default     = 4
  description = "Maximum node count for EKS node group."
}
