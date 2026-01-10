# =============================================================================
# AZURE BACKEND TEMPLATE
# =============================================================================
# This template dynamically generates backend configuration based on
# environment settings. Supports multiple backend types.
#
# Template Variables:
#   - backend_type: local, azurerm, or s3
#   - storage_account_name: Azure storage account for state
#   - container_name: Blob container name
#   - resource_group_name: Resource group containing storage
#   - key: State file path/key
#   - use_msi: Whether to use Managed Identity
#   - use_azuread_auth: Whether to use Azure AD auth
# =============================================================================

%{ if backend_type == "azurerm" ~}
# Azure Blob Storage Backend (Production Recommended)
terraform {
  backend "azurerm" {
    resource_group_name  = "${resource_group_name}"
    storage_account_name = "${storage_account_name}"
    container_name       = "${container_name}"
    key                  = "${key}"
    
    # Authentication method
%{ if use_msi ~}
    use_msi              = true
%{ endif ~}
%{ if use_azuread_auth ~}
    use_azuread_auth     = true
%{ endif ~}
    
    # Encryption
    # State files are automatically encrypted with Storage Service Encryption
    # For additional security, enable customer-managed keys on the storage account
  }
}

# =============================================================================
# Backend Security Configuration Notes:
# =============================================================================
# 1. Enable soft delete on the blob container for recovery
# 2. Enable versioning to track state changes
# 3. Configure RBAC - only pipeline service principals should have access
# 4. Enable firewall rules - restrict to Azure DevOps/GitHub runners
# 5. Enable private endpoints for VNet-integrated access
# 6. Configure container-level immutability policies for compliance
# =============================================================================

%{ endif ~}
%{ if backend_type == "local" ~}
# Local Backend (Development Only)
terraform {
  backend "local" {
    path = "${local_state_path}"
  }
}

# WARNING: Local backend should only be used for development/testing
# State is stored on local filesystem and not shared across team members
%{ endif ~}
%{ if backend_type == "s3" ~}
# AWS S3 Backend (For hybrid Azure/AWS environments)
terraform {
  backend "s3" {
    bucket         = "${s3_bucket}"
    key            = "${key}"
    region         = "${s3_region}"
    encrypt        = true
    dynamodb_table = "${dynamodb_table}"
    
%{ if use_role_arn ~}
    role_arn       = "${role_arn}"
%{ endif ~}
  }
}
%{ endif ~}

# =============================================================================
# State Lock Information
# =============================================================================
# Backend Type: ${backend_type}
# Environment:  ${environment}
# Module:       ${module_name}
# Generated:    ${timestamp}
#
# State locking is automatically handled by the Azure Blob Storage backend
# using blob leases. This prevents concurrent modifications.
# =============================================================================
