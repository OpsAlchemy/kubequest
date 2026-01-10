# Root Terragrunt Configuration
# This file contains common configuration that will be inherited by all child modules

# Configure remote state backend
remote_state {
  backend = "local"
  
  config = {
    path = "${get_parent_terragrunt_dir()}/terraform.tfstate.d/${path_relative_to_include()}/terraform.tfstate"
  }
  
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}

# Generate provider configuration
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
  }
}
EOF
}

# Common inputs for all environments
inputs = {
  project_name = "terragrunt-demo"
}
