# Base - Standalone Terraform project

terraform {
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "Terraform"
    }
  }
}

# Local values used across resources
locals {
  environment  = var.environment
  project_name = var.project_name
  common_tags = merge({
    Environment = local.environment
    Project     = local.project_name
    ManagedBy   = "Terraform"
  }, var.tags)
}

# Example resource (uncomment and customize if needed)
# resource "aws_vpc" "main" {
#   cidr_block           = var.vpc_cidr
#   enable_dns_hostnames = true
#   enable_dns_support   = true
#
#   tags = merge(
#     local.common_tags,
#     {
#       Name = "${local.project_name}-vpc"
#     }
#   )
# }
