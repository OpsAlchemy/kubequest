# =============================================================================
# DATABASE MODULE - COMPLEX TERRAGRUNT CONFIGURATION
# =============================================================================
# Depends on: network, storage, compute
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

dependency "storage" {
  config_path = "../storage"
  
  mock_outputs = {
    storage_account_ids          = { data = "mock-storage-id", diag = "mock-diag-id" }
    diagnostics_storage_endpoint = "https://mock.blob.core.windows.net"
    backup_container_url         = "https://mock.blob.core.windows.net/backups"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "compute" {
  config_path = "../compute"
  
  mock_outputs = {
    vmss_ids            = { web = "mock-vmss-web", app = "mock-vmss-app" }
    app_subnet_id       = "mock-app-subnet"
    compute_identity_id = "mock-identity"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# =============================================================================
# LOCAL VARIABLES
# =============================================================================
locals {
  module_name = "database"
  path_parts  = split("/", path_relative_to_include())
  region      = local.path_parts[1]
  environment = local.path_parts[2]
  
  # Database SKUs per environment
  db_skus = {
    dev     = "GP_Gen5_2"
    staging = "GP_Gen5_4"
    prod    = "BC_Gen5_8"
  }
  
  # Storage limits per environment (GB)
  db_storage = {
    dev     = 32
    staging = 128
    prod    = 512
  }
  
  # Backup retention (days)
  backup_retention = {
    dev     = 7
    staging = 14
    prod    = 35
  }
  
  common_tags = {
    Module      = local.module_name
    Region      = local.region
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    DependsOn   = "network,storage,compute"
    DataClass   = "Confidential"
  }
  
  deploy_timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp())
}

# =============================================================================
# TERRAFORM SOURCE WITH HOOKS
# =============================================================================
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//database"
  
  before_hook "check_dependencies" {
    commands = ["plan", "apply"]
    execute  = ["echo", "🔗 Database depends on: network, storage, compute"]
  }
  
  before_hook "database_backup_check" {
    commands = ["apply"]
    execute  = ["echo", "💾 Backup location configured"]
  }
  
  before_hook "database_deploy_start" {
    commands = ["apply"]
    execute  = ["echo", "🗄️  Deploying database resources for ${local.environment}"]
  }
  
  after_hook "database_deployed" {
    commands     = ["apply"]
    execute      = ["echo", "✅ Database deployment completed!"]
    run_on_error = false
  }
  
  # Error hook (commented - runs on both success/failure with run_on_error=true)
  # after_hook "database_failure" {
  #   commands     = ["apply", "plan"]
  #   execute      = ["echo", "❌ Database deployment failed!"]
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
    # Auto-generated - Database Module
    # Depends on: network, storage, compute
    # Timestamp: ${local.deploy_timestamp}
  EOF
}

# =============================================================================
# INPUTS
# =============================================================================
inputs = {
  project_name        = "azure-complex-${local.environment}"
  resource_group_name = "rg-${local.environment}-${local.region}-database"
  location            = local.region == "eastus" ? "East US" : "West Europe"
  
  # From dependencies
  vnet_id                      = dependency.network.outputs.vnet_id
  subnet_ids                   = dependency.network.outputs.subnet_ids
  data_subnet_id               = dependency.network.outputs.subnet_ids.data
  diagnostics_storage_endpoint = dependency.storage.outputs.diagnostics_storage_endpoint
  backup_container_url         = dependency.storage.outputs.backup_container_url
  
  # Azure SQL Server config
  sql_server = {
    name                          = "sql-${local.environment}-${local.region}"
    version                       = "12.0"
    administrator_login           = "sqladmin"
    minimum_tls_version           = "1.2"
    public_network_access_enabled = false
  }
  
  # Azure SQL Databases
  databases = {
    "sqldb-app-${local.environment}" = {
      sku_name                            = local.db_skus[local.environment]
      max_size_gb                         = local.db_storage[local.environment]
      zone_redundant                      = local.environment == "prod"
      read_scale                          = local.environment == "prod"
      short_term_retention_days           = local.backup_retention[local.environment]
      transparent_data_encryption_enabled = true
    }
    
    "sqldb-audit-${local.environment}" = {
      sku_name                            = "GP_Gen5_2"
      max_size_gb                         = 32
      zone_redundant                      = false
      read_scale                          = false
      short_term_retention_days           = 7
      transparent_data_encryption_enabled = true
    }
  }
  
  # Cosmos DB (staging/prod only)
  enable_cosmosdb = local.environment != "dev"
  cosmosdb_config = local.environment != "dev" ? {
    name              = "cosmos-${local.environment}-${local.region}"
    offer_type        = "Standard"
    kind              = "GlobalDocumentDB"
    consistency_level = local.environment == "prod" ? "Strong" : "Session"
  } : null
  
  # Redis Cache
  redis_config = {
    name     = "redis-${local.environment}-${local.region}"
    capacity = local.environment == "prod" ? 2 : 0
    family   = local.environment == "prod" ? "P" : "C"
    sku_name = local.environment == "prod" ? "Premium" : "Basic"
  }
  
  enable_private_endpoints = local.environment != "dev"
  
  environment = local.environment
  tags        = local.common_tags
}
