# =============================================================================
# MONITORING MODULE - COMPLEX TERRAGRUNT CONFIGURATION
# =============================================================================
# Depends on: ALL modules (network, storage, compute, database)
# This is the FINAL module in the dependency chain.
# =============================================================================

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# =============================================================================
# DEPENDENCIES - All modules
# =============================================================================
dependency "network" {
  config_path = "../network"
  
  mock_outputs = {
    vnet_id             = "mock-vnet-id"
    subnet_ids          = { web = "mock-web", app = "mock-app", data = "mock-data", mgmt = "mock-mgmt" }
    resource_group_name = "rg-mock-network"
    nsg_ids             = { web = "mock-nsg-web", app = "mock-nsg-app" }
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "storage" {
  config_path = "../storage"
  
  mock_outputs = {
    storage_account_ids          = { data = "mock-storage-id", diag = "mock-diag-id" }
    diagnostics_storage_endpoint = "https://mock.blob.core.windows.net"
    diagnostics_storage_id       = "mock-diag-storage-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "compute" {
  config_path = "../compute"
  
  mock_outputs = {
    vmss_ids          = { web = "mock-vmss-web", app = "mock-vmss-app" }
    vmss_resource_ids = ["mock-vmss-id-1", "mock-vmss-id-2"]
    aks_cluster_id    = null
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

dependency "database" {
  config_path = "../database"
  
  mock_outputs = {
    sql_server_id    = "mock-sql-server-id"
    sql_database_ids = { app = "mock-db-app", audit = "mock-db-audit" }
    cosmosdb_id      = null
    redis_id         = "mock-redis-id"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# =============================================================================
# LOCAL VARIABLES
# =============================================================================
locals {
  module_name = "monitoring"
  path_parts  = split("/", path_relative_to_include())
  region      = local.path_parts[1]
  environment = local.path_parts[2]
  
  # Log retention per environment (days)
  log_retention = {
    dev     = 30
    staging = 60
    prod    = 365
  }
  
  # Alert thresholds per environment
  alert_thresholds = {
    dev = {
      cpu_critical    = 95
      cpu_warning     = 85
      memory_critical = 95
      memory_warning  = 85
    }
    staging = {
      cpu_critical    = 90
      cpu_warning     = 75
      memory_critical = 90
      memory_warning  = 75
    }
    prod = {
      cpu_critical    = 85
      cpu_warning     = 70
      memory_critical = 85
      memory_warning  = 70
    }
  }
  
  common_tags = {
    Module      = local.module_name
    Region      = local.region
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    DependsOn   = "network,storage,compute,database"
  }
  
  deploy_timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp())
}

# =============================================================================
# TERRAFORM SOURCE WITH HOOKS
# =============================================================================
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//monitoring"
  
  before_hook "validate_all_dependencies" {
    commands = ["plan", "apply"]
    execute  = ["echo", "🔗 Monitoring depends on: ALL infrastructure modules"]
  }
  
  before_hook "monitoring_deploy_start" {
    commands = ["apply"]
    execute  = ["echo", "📈 Deploying monitoring stack for ${local.environment}..."]
  }
  
  after_hook "monitoring_deployed" {
    commands     = ["apply"]
    execute      = ["echo", "✅ Monitoring deployment completed! All infrastructure is now observable."]
    run_on_error = false
  }
  
  after_hook "show_dashboard_url" {
    commands     = ["apply"]
    execute      = ["echo", "🔗 Azure Portal: https://portal.azure.com"]
    run_on_error = false
  }
  
  # Error hook (commented - runs on both success/failure with run_on_error=true)
  # after_hook "monitoring_failure" {
  #   commands     = ["apply", "plan"]
  #   execute      = ["echo", "❌ Monitoring deployment failed!"]
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
    # Auto-generated - Monitoring Module
    # Depends on: ALL modules
    # Timestamp: ${local.deploy_timestamp}
  EOF
}

# =============================================================================
# INPUTS
# =============================================================================
inputs = {
  project_name        = "azure-complex-${local.environment}"
  resource_group_name = "rg-${local.environment}-${local.region}-monitoring"
  location            = local.region == "eastus" ? "East US" : "West Europe"
  
  # Resources to monitor (from dependencies)
  monitored_resources = {
    network = {
      vnet_id = dependency.network.outputs.vnet_id
      nsg_ids = dependency.network.outputs.nsg_ids
    }
    storage = {
      storage_id           = dependency.storage.outputs.diagnostics_storage_id
      diagnostics_endpoint = dependency.storage.outputs.diagnostics_storage_endpoint
    }
    compute = {
      vmss_resource_ids = dependency.compute.outputs.vmss_resource_ids
      aks_cluster_id    = try(dependency.compute.outputs.aks_cluster_id, null)
    }
    database = {
      sql_server_id    = dependency.database.outputs.sql_server_id
      sql_database_ids = dependency.database.outputs.sql_database_ids
      redis_id         = dependency.database.outputs.redis_id
      cosmosdb_id      = try(dependency.database.outputs.cosmosdb_id, null)
    }
  }
  
  # Log Analytics Workspace
  log_analytics = {
    name              = "log-${local.environment}-${local.region}"
    sku               = local.environment == "prod" ? "PerGB2018" : "Free"
    retention_in_days = local.log_retention[local.environment]
    
    solutions = local.environment != "dev" ? [
      "ContainerInsights",
      "SecurityInsights",
      "VMInsights",
      "SQLAssessment"
    ] : ["AzureActivity"]
  }
  
  # Application Insights
  application_insights = {
    name                = "appi-${local.environment}-${local.region}"
    application_type    = "web"
    retention_in_days   = local.log_retention[local.environment]
    sampling_percentage = local.environment == "prod" ? 100 : 50
  }
  
  # Metric alerts
  metric_alerts = {
    "cpu-critical-${local.environment}" = {
      description = "CPU usage critical"
      severity    = 0
      threshold   = local.alert_thresholds[local.environment].cpu_critical
    }
    "cpu-warning-${local.environment}" = {
      description = "CPU usage elevated"
      severity    = 2
      threshold   = local.alert_thresholds[local.environment].cpu_warning
    }
  }
  
  # Action groups
  action_groups = {
    "ag-critical-${local.environment}" = {
      short_name = "Critical"
      email_receivers = local.environment == "prod" ? [
        { name = "OnCall", email_address = "oncall@example.com" }
      ] : [
        { name = "Dev", email_address = "dev@example.com" }
      ]
    }
  }
  
  enable_diagnostic_settings = true
  
  environment = local.environment
  tags        = local.common_tags
}
