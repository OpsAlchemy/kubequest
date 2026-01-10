# =============================================================================
# COMPUTE MODULE - COMPLEX TERRAGRUNT CONFIGURATION
# =============================================================================
# Depends on: network, storage
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
    storage_account_ids          = { data = "mock-storage-id" }
    diagnostics_storage_endpoint = "https://mock.blob.core.windows.net"
  }
  mock_outputs_allowed_terraform_commands = ["validate", "plan", "init"]
}

# =============================================================================
# LOCAL VARIABLES
# =============================================================================
locals {
  module_name = "compute"
  path_parts  = split("/", path_relative_to_include())
  region      = local.path_parts[1]
  environment = local.path_parts[2]
  
  # VM sizing per environment
  vm_sizes = {
    dev     = { web = "Standard_B2s", app = "Standard_B2ms" }
    staging = { web = "Standard_D2s_v3", app = "Standard_D4s_v3" }
    prod    = { web = "Standard_D4s_v3", app = "Standard_D8s_v3" }
  }
  
  # Instance counts per environment
  instance_counts = {
    dev     = { web = 1, app = 1 }
    staging = { web = 2, app = 2 }
    prod    = { web = 3, app = 4 }
  }
  
  common_tags = {
    Module      = local.module_name
    Region      = local.region
    Environment = local.environment
    ManagedBy   = "Terragrunt"
    DependsOn   = "network,storage"
  }
  
  deploy_timestamp = formatdate("YYYY-MM-DD-hh-mm", timestamp())
}

# =============================================================================
# TERRAFORM SOURCE WITH HOOKS
# =============================================================================
terraform {
  source = "${get_parent_terragrunt_dir()}/modules//compute"
  
  before_hook "check_dependencies" {
    commands = ["plan", "apply"]
    execute  = ["echo", "🔗 Compute depends on: network, storage"]
  }
  
  before_hook "compute_deploy_start" {
    commands = ["apply"]
    execute  = ["echo", "🖥️  Deploying compute resources for ${local.environment}"]
  }
  
  after_hook "compute_deployed" {
    commands     = ["apply"]
    execute      = ["echo", "✅ Compute deployment completed!"]
    run_on_error = false
  }
  
  # Error hook (commented - runs on both success/failure with run_on_error=true)
  # after_hook "compute_failure" {
  #   commands     = ["apply", "plan"]
  #   execute      = ["echo", "❌ Compute deployment failed!"]
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
    # Auto-generated - Compute Module
    # Depends on: network, storage
    # Timestamp: ${local.deploy_timestamp}
  EOF
}

# =============================================================================
# INPUTS
# =============================================================================
inputs = {
  project_name        = "azure-complex-${local.environment}"
  resource_group_name = "rg-${local.environment}-${local.region}-compute"
  location            = local.region == "eastus" ? "East US" : "West Europe"
  
  # From dependencies
  vnet_id                      = dependency.network.outputs.vnet_id
  subnet_ids                   = values(dependency.network.outputs.subnet_ids)
  diagnostics_storage_endpoint = dependency.storage.outputs.diagnostics_storage_endpoint
  
  # Virtual Machine Scale Sets config
  vmss_configs = {
    web = {
      name      = "vmss-web-${local.environment}"
      instances = local.instance_counts[local.environment].web
      sku       = local.vm_sizes[local.environment].web
      subnet_id = dependency.network.outputs.subnet_ids.web
      
      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
      
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = local.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
      }
      
      autoscale = {
        min_count          = local.environment == "prod" ? 2 : 1
        max_count          = local.instance_counts[local.environment].web * 2
        cpu_threshold_up   = 75
        cpu_threshold_down = 25
      }
    }
    
    app = {
      name      = "vmss-app-${local.environment}"
      instances = local.instance_counts[local.environment].app
      sku       = local.vm_sizes[local.environment].app
      subnet_id = dependency.network.outputs.subnet_ids.app
      
      source_image_reference = {
        publisher = "Canonical"
        offer     = "0001-com-ubuntu-server-jammy"
        sku       = "22_04-lts-gen2"
        version   = "latest"
      }
      
      os_disk = {
        caching              = "ReadWrite"
        storage_account_type = local.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
      }
      
      autoscale = {
        min_count          = local.environment == "prod" ? 3 : 1
        max_count          = local.instance_counts[local.environment].app * 2
        cpu_threshold_up   = 70
        cpu_threshold_down = 20
      }
    }
  }
  
  # AKS config (prod only)
  enable_aks = local.environment == "prod"
  aks_config = local.environment == "prod" ? {
    kubernetes_version = "1.28"
    node_count         = 3
    node_vm_size       = "Standard_D4s_v3"
    network_plugin     = "azure"
    network_policy     = "calico"
  } : null
  
  environment = local.environment
  tags        = local.common_tags
}
