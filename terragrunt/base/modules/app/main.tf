# Simple Terraform module for demonstration
# This module creates a simple null resource to demonstrate Terragrunt

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "app_name" {
  description = "Application name"
  type        = string
}

variable "project_name" {
  description = "Project name from root config"
  type        = string
}

variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
}

# Create a null resource to demonstrate the module
resource "null_resource" "app" {
  count = var.instance_count

  triggers = {
    environment  = var.environment
    app_name     = var.app_name
    project_name = var.project_name
    instance_id  = count.index
    timestamp    = timestamp()
  }

  provisioner "local-exec" {
    command = "echo 'Deploying ${var.app_name} instance ${count.index} in ${var.environment} environment'"
  }
}

output "app_info" {
  description = "Application deployment information"
  value = {
    environment    = var.environment
    app_name       = var.app_name
    project_name   = var.project_name
    instance_count = var.instance_count
    instances      = [for i in range(var.instance_count) : "instance-${i}"]
  }
}

output "deployment_message" {
  description = "Deployment message"
  value       = "Successfully deployed ${var.instance_count} instance(s) of ${var.app_name} in ${var.environment}"
}
