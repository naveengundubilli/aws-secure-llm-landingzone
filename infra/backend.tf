terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.30"
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
