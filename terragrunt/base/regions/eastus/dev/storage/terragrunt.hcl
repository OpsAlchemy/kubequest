# =============================================================================
# STORAGE MODULE - COMPLEX TERRAGRUNT CONFIGURATION
# =============================================================================
# Depends on: network
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# =============================================================================
# DEPENDENCIES
# =============================================================================
dependency "network" {
  config_path = "../network"
  
  mock_outputs = {
    vnet_id             = "mock-vnet-id"
    subnet_ids          = { web = "mock-web", app = "mock-app", data = "mock-data" }
    resource_group_name = "rg-mock-network"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# =============================================================================
# LOCAL VARIABLES
# =============================================================================
locals {
  module_name = "storage"
  path_parts  = split("/", path_relative_to_include())
  region      = local.path_parts[1]
  environment = local.path_parts[2]
  
  # Storage account naming (must be globally unique, lowercase, no hyphens)
  storage_prefix = "st${local.environment}${local.region}"
  
  # Replication type per environment
  replication_types = {
    dev     = "LRS"
    staging = "GRS"
    prod    = "RAGRS"
  }
  
  # Storage tiers per environment
  access_tiers = {
    dev     = "Hot"
    staging = "Hot"
    prod    = "Hot"
  }
  
  common_tags = {
    Module      = local.module_name
    Region      = local.region
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    DependsOn   = "network"
  }
  
  deploy_timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp())
}

# =============================================================================
# TERRAFORM SOURCE WITH HOOKS
# =============================================================================
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//storage"
  
  before_hook "check_network_dependency" {
    commands = ["plan", "apply"]
    execute  = ["echo", "🔗 Storage depends on network: ${dependency.network.outputs.vnet_id}"]
  }
  
  before_hook "storage_deploy_start" {
    commands = ["apply"]
    execute  = ["echo", "💾 Deploying storage resources for ${local.environment}"]
  }
  
  after_hook "storage_deployed" {
    commands     = ["apply"]
    execute      = ["echo", "✅ Storage deployment completed!"]
    run_on_error = false
  }
  
  # Error hook (commented - runs on both success/failure with run_on_error=true)
  # after_hook "storage_failure" {
  #   commands     = ["apply", "plan"]
  #   execute      = ["echo", "❌ Storage deployment failed!"]
  #   run_on_error = true
  # }
}

# =============================================================================
# GENERATE BLOCKS
# =============================================================================
generate "deployment_info" {
  path      = "_deployment_info.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    # Auto-generated - Storage Module
    # Depends on: network
    # Timestamp: ${local.deploy_timestamp}
  EOF
}

# =============================================================================
# INPUTS
# =============================================================================
inputs = {
  project_name        = "azure-complex-${local.environment}"
  resource_group_name = "rg-${local.environment}-${local.region}-storage"
  location            = local.region == "eastus" ? "East US" : "West Europe"
  
  # From dependencies
  vnet_id    = dependency.network.outputs.vnet_id
  subnet_ids = dependency.network.outputs.subnet_ids
  
  # Storage accounts configuration
  storage_accounts = {
    "${local.storage_prefix}data" = {
      account_tier             = "Standard"
      account_replication_type = local.replication_types[local.environment]
      access_tier              = local.access_tiers[local.environment]
      
      blob_properties = {
        versioning_enabled       = local.environment == "prod"
        change_feed_enabled      = local.environment == "prod"
        delete_retention_days    = local.environment == "prod" ? 30 : 7
        container_delete_retention_days = local.environment == "prod" ? 30 : 7
      }
      
      network_rules = {
        default_action = local.environment == "prod" ? "Deny" : "Allow"
        bypass         = ["AzureServices"]
      }
      
      containers = ["data", "logs", "backups"]
    }
    
    "${local.storage_prefix}diag" = {
      account_tier             = "Standard"
      account_replication_type = "LRS"
      access_tier              = "Hot"
      
      blob_properties = {
        delete_retention_days = 7
      }
      
      containers = ["diagnostics", "metrics"]
    }
  }
  
  # Azure Files shares
  file_shares = local.environment != "dev" ? {
    "share-app-config" = {
      quota = 50
      tier  = "TransactionOptimized"
    }
  } : {}
  
  # Private endpoints
  enable_private_endpoints = local.environment == "prod"
  
  environment = local.environment
  tags        = local.common_tags
}
