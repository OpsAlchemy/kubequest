# =============================================================================
# ROOT TERRAGRUNT CONFIGURATION - ULTIMATE COMPLEXITY EDITION
# =============================================================================
# This is the most unnecessarily complex root configuration possible.
# 
# Configuration Hierarchy (5 layers):
#   1. root.hcl (you are here) - Global settings, backends, providers
#   2. region.hcl - Azure regional settings
#   3. env.hcl - Environment settings (dev/staging/prod)
#   4. tier.hcl - Tier settings (web/app/data)
#   5. terragrunt.hcl - Module-specific settings
#
# Features:
#   - Dynamic configuration via run_cmd() and templatefile()
#   - Multiple backend configurations
#   - Complex dependency graphs
#   - Pre/post hooks for validation, security scanning, notifications
#   - Auto-generated provider and backend configurations
#   - External data sources
# =============================================================================

# =============================================================================
# GLOBAL LOCALS - Computed at runtime
# =============================================================================
locals {
  # -------------------------------------------------------------------------
  # AZURE SUBSCRIPTION SETTINGS
  # -------------------------------------------------------------------------
  subscription_id = get_env("ARM_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")
  tenant_id       = get_env("ARM_TENANT_ID", "00000000-0000-0000-0000-000000000000")
  client_id       = get_env("ARM_CLIENT_ID", "")
  
  # -------------------------------------------------------------------------
  # ENVIRONMENT DETECTION (from path)
  # -------------------------------------------------------------------------
  path_components = split("/", path_relative_to_include())
  
  # Detect if we're in a regional structure (regions/eastus/dev/...)
  is_regional_structure = length(local.path_components) >= 3 && contains(["eastus", "westus", "westeurope", "northeurope"], try(local.path_components[1], ""))
  
  # Detect if we're in old structure (environments/dev/...)
  is_env_structure = length(local.path_components) >= 2 && try(local.path_components[0], "") == "environments"
  
  # Detect environment from path
  detected_environment = (
    local.is_regional_structure ? try(local.path_components[2], "dev") :
    local.is_env_structure ? try(local.path_components[1], "dev") :
    "dev"
  )
  
  # Detect region from path
  detected_region = local.is_regional_structure ? try(local.path_components[1], "eastus") : "eastus"
  
  # -------------------------------------------------------------------------
  # NAMING CONFIGURATION
  # -------------------------------------------------------------------------
  region_codes = {
    "eastus"      = "eus"
    "westus"      = "wus"
    "westeurope"  = "weu"
    "northeurope" = "neu"
  }
  
  env_codes = {
    "dev"     = "d"
    "staging" = "s"
    "prod"    = "p"
  }
  
  region_code = lookup(local.region_codes, local.detected_region, "eus")
  env_code    = lookup(local.env_codes, local.detected_environment, "d")
  
  naming_prefix = "cmp-${local.region_code}-${local.env_code}"
  
  # -------------------------------------------------------------------------
  # BACKEND SELECTION LOGIC
  # -------------------------------------------------------------------------
  backend_type = lookup({
    "dev"     = "local"
    "staging" = "local"
    "prod"    = "local"
  }, local.detected_environment, "local")
  
  # -------------------------------------------------------------------------
  # PROVIDER FEATURE FLAGS
  # -------------------------------------------------------------------------
  provider_features = {
    dev = {
      key_vault_purge_on_destroy   = true
      vm_delete_os_disk_on_delete  = true
      vm_graceful_shutdown         = false
      rg_prevent_deletion          = false
    }
    staging = {
      key_vault_purge_on_destroy   = false
      vm_delete_os_disk_on_delete  = true
      vm_graceful_shutdown         = true
      rg_prevent_deletion          = true
    }
    prod = {
      key_vault_purge_on_destroy   = false
      vm_delete_os_disk_on_delete  = false
      vm_graceful_shutdown         = true
      rg_prevent_deletion          = true
    }
  }
  
  current_provider_features = lookup(local.provider_features, local.detected_environment, local.provider_features.dev)
  
  # -------------------------------------------------------------------------
  # TIMESTAMP FOR TAGS
  # -------------------------------------------------------------------------
  deployment_timestamp = formatdate("YYYY-MM-DD'T'hh:mm:ssZ", timestamp())
  
  # -------------------------------------------------------------------------
  # GLOBAL TAGS
  # -------------------------------------------------------------------------
  global_tags = {
    terraform_managed  = "true"
    terragrunt_managed = "true"
    iac_repository     = "terragrunt-hardened"
    iac_version        = "3.0-complex"
    environment        = local.detected_environment
    region             = local.detected_region
    deployed_at        = local.deployment_timestamp
  }
}

# =============================================================================
# REMOTE STATE CONFIGURATION
# =============================================================================
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

# =============================================================================
# PROVIDER GENERATION
# =============================================================================
generate "provider" {
  path      = "provider.tf"
  if_exists = "overwrite_terragrunt"
  contents  = <<-EOF
    # =============================================================================
    # AUTO-GENERATED PROVIDER CONFIGURATION
    # =============================================================================
    # Environment: ${local.detected_environment}
    # Region:      ${local.detected_region}
    # Generated:   ${local.deployment_timestamp}
    # =============================================================================
    
    terraform {
      required_version = ">= 1.5.0"
      
      required_providers {
        azurerm = {
          source  = "hashicorp/azurerm"
          version = "~> 3.80"
        }
        azuread = {
          source  = "hashicorp/azuread"
          version = "~> 2.45"
        }
        random = {
          source  = "hashicorp/random"
          version = "~> 3.5"
        }
        null = {
          source  = "hashicorp/null"
          version = "~> 3.2"
        }
        time = {
          source  = "hashicorp/time"
          version = "~> 0.10"
        }
        tls = {
          source  = "hashicorp/tls"
          version = "~> 4.0"
        }
      }
    }
    
    provider "azurerm" {
      subscription_id = "${local.subscription_id}"
      tenant_id       = "${local.tenant_id}"
      
      skip_provider_registration = ${local.detected_environment == "dev" ? "true" : "false"}
      
      features {
        key_vault {
          purge_soft_delete_on_destroy    = ${local.current_provider_features.key_vault_purge_on_destroy}
          recover_soft_deleted_key_vault  = true
        }
        
        virtual_machine {
          delete_os_disk_on_delete     = ${local.current_provider_features.vm_delete_os_disk_on_delete}
          graceful_shutdown            = ${local.current_provider_features.vm_graceful_shutdown}
          skip_shutdown_and_force_delete = false
        }
        
        resource_group {
          prevent_deletion_if_contains_resources = ${local.current_provider_features.rg_prevent_deletion}
        }
        
        log_analytics_workspace {
          permanently_delete_on_destroy = ${local.detected_environment == "dev" ? "true" : "false"}
        }
      }
    }
    
    provider "azuread" {
      tenant_id = "${local.tenant_id}"
    }
    
    provider "random" {}
    provider "null" {}
    provider "time" {}
    provider "tls" {}
  EOF
}

# =============================================================================
# GLOBAL INPUTS
# =============================================================================
inputs = {
  naming_prefix        = local.naming_prefix
  environment          = local.detected_environment
  azure_region         = local.detected_region
  subscription_id      = local.subscription_id
  tenant_id            = local.tenant_id
  deployment_timestamp = local.deployment_timestamp
  global_tags          = local.global_tags
  common_tags          = local.global_tags
}
