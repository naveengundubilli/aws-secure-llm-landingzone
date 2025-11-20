environment            = "prod"
project_name           = "aws-secure-llm-landingzone"
aws_region             = "ap-southeast-2"

org_master_account_id  = "222222222222"

# Separate CIDR for prod to keep it isolated from dev and peering-ready
vpc_cidr               = "10.30.0.0/16"

# Tighter admin ranges, ideally corporate VPN only
allowed_admin_cidrs    = [
  "198.51.100.0/24"
]

eks_version            = "1.30"
eks_node_instance_type = "m5.large"
eks_node_min_size      = 3
eks_node_max_size      = 6
