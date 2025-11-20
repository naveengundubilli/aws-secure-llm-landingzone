variable "project_name"       { type = string }
variable "environment"        { type = string }
variable "vpc_id"             { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "tags"               { type = map(string) }

variable "peer_vpc_id" {
  type        = string
  default     = ""
  description = "Optional peer VPC ID for VPC peering."
}
