# =============================================================================
# AZURE PROVIDER TEMPLATE
# =============================================================================
# This template is used to dynamically generate provider.tf based on
# environment and region settings.
#
# Template Variables:
#   - azure_region: Azure region name
#   - subscription_id: Azure subscription ID
#   - tenant_id: Azure tenant ID
#   - environment: Environment name (dev/staging/prod)
#   - enable_features: Map of Azure provider features
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
%{ if enable_kubernetes ~}
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12"
    }
%{ endif ~}
  }
}

# Azure Resource Manager Provider
provider "azurerm" {
  subscription_id = "${subscription_id}"
  tenant_id       = "${tenant_id}"
  
  # Skip provider registration for faster deployment
  skip_provider_registration = ${skip_provider_registration}
  
  features {
    # Key Vault features
    key_vault {
      purge_soft_delete_on_destroy    = ${key_vault_purge_on_destroy}
      recover_soft_deleted_key_vault  = ${key_vault_recover_soft_deleted}
      purge_soft_deleted_keys_on_destroy = ${key_vault_purge_keys_on_destroy}
      purge_soft_deleted_secrets_on_destroy = ${key_vault_purge_secrets_on_destroy}
      purge_soft_deleted_certificates_on_destroy = ${key_vault_purge_certificates_on_destroy}
    }
    
    # Virtual Machine features
    virtual_machine {
      delete_os_disk_on_delete     = ${vm_delete_os_disk_on_delete}
      graceful_shutdown            = ${vm_graceful_shutdown}
      skip_shutdown_and_force_delete = ${vm_skip_shutdown_force_delete}
    }
    
    # Virtual Machine Scale Set features
    virtual_machine_scale_set {
      force_delete                  = ${vmss_force_delete}
      roll_instances_when_required  = ${vmss_roll_instances}
      scale_to_zero_before_deletion = ${vmss_scale_to_zero}
    }
    
    # Resource Group features
    resource_group {
      prevent_deletion_if_contains_resources = ${rg_prevent_deletion}
    }
    
    # Log Analytics Workspace features
    log_analytics_workspace {
      permanently_delete_on_destroy = ${law_permanent_delete}
    }
    
    # Cognitive Account features
    cognitive_account {
      purge_soft_delete_on_destroy = ${cognitive_purge_on_destroy}
    }
    
%{ if enable_api_management ~}
    # API Management features
    api_management {
      purge_soft_delete_on_destroy = ${apim_purge_on_destroy}
      recover_soft_deleted         = ${apim_recover_soft_deleted}
    }
%{ endif ~}
    
%{ if enable_app_configuration ~}
    # App Configuration features
    app_configuration {
      purge_soft_delete_on_destroy = ${appconfig_purge_on_destroy}
      recover_soft_deleted         = ${appconfig_recover_soft_deleted}
    }
%{ endif ~}
  }
}

# Azure Active Directory Provider
provider "azuread" {
  tenant_id = "${tenant_id}"
}

# Random Provider
provider "random" {}

# Null Provider (for local-exec and triggers)
provider "null" {}

# Time Provider (for time-based resources)
provider "time" {}

# TLS Provider (for certificate generation)
provider "tls" {}

%{ if enable_kubernetes ~}
# Kubernetes Provider (configured after AKS creation)
provider "kubernetes" {
  host                   = data.azurerm_kubernetes_cluster.main.kube_config[0].host
  client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
  client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
  cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
}

# Helm Provider
provider "helm" {
  kubernetes {
    host                   = data.azurerm_kubernetes_cluster.main.kube_config[0].host
    client_certificate     = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
    client_key             = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(data.azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
  }
}
%{ endif ~}

# =============================================================================
# Provider Configuration Summary (for documentation)
# =============================================================================
# Region:       ${azure_region}
# Environment:  ${environment}
# Subscription: ${subscription_id}
# Generated:    ${timestamp}
# =============================================================================
