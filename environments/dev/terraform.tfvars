environment            = "dev"
project_name           = "aws-secure-llm-landingzone"
aws_region             = "ap-southeast-2"

# Replace with your actual org management account ID if you demo SCPs
org_master_account_id  = "111111111111"

# Smaller CIDR for dev
vpc_cidr               = "10.20.0.0/16"

# Your office / home IP or VPN range for admin/bastion access if needed
allowed_admin_cidrs    = [
  "203.0.113.10/32"
]

# EKS specific
eks_version            = "1.30"
eks_node_instance_type = "t3.medium"
eks_node_min_size      = 2
eks_node_max_size      = 4
