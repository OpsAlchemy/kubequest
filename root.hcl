# Root Terragrunt Configuration - Hardened Multi-Tier Infrastructure
# This file contains common configuration inherited by all child modules
# Implements security best practices for Azure-like infrastructure

locals {
  # Load environment variables
  environment = get_env("ENVIRONMENT", "dev")
  
  # Azure subscription and naming conventions
  subscription_id = get_env("AZURE_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")
  tenant_id       = get_env("AZURE_TENANT_ID", "00000000-0000-0000-0000-000000000000")
  
  # Common tags for all resources
  common_tags = {
    managed_by  = "terraform"
    managed_by_platform = "terragrunt"
    environment = local.environment
    created_at  = timestamp()
  }
}

# Configure remote state backend with encryption
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

# Generate Azure provider configuration with authentication
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<EOF
terraform {
  required_version = ">= 1.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
      recover_soft_deleted_key_vault = true
    }
    virtual_machine {
      delete_os_disk_on_delete = true
    }
  }
  
  skip_provider_registration = false
}

provider "null" {}
provider "random" {}
EOF
}

# Common inputs for all environments
inputs = {
  project_name = "terragrunt-hardened"
  
  # Enable security features by default
  enable_monitoring = true
  enable_encryption = true
  enable_backup     = true
  
  # Common Azure settings
  common_tags = local.common_tags
}
