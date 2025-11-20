terraform {
  required_version = "= 1.14.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "= 6.21.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "= 2.38.0"
    }
  }

  # TODO: adjust bucket, key, region and dynamodb_table to your environment.
  backend "s3" {
    bucket         = "CHANGE-ME-tf-state-bucket-secure-landingzone"
    key            = "infra/terraform.tfstate"
    region         = "ap-southeast-2"
    dynamodb_table = "CHANGE-ME-tf-lock-table"
    encrypt        = true
  }
}
