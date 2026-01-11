# Base Module - Outputs

output "environment" {
  description = "Environment name"
  value       = var.environment
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

output "common_tags" {
  description = "Common tags applied to all resources"
  value       = local.common_tags
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

# Example VPC outputs (uncomment when VPC is created)
# output "vpc_id" {
#   description = "VPC ID"
#   value       = aws_vpc.main.id
# }
#
# output "vpc_cidr" {
#   description = "VPC CIDR block"
#   value       = aws_vpc.main.cidr_block
# }
