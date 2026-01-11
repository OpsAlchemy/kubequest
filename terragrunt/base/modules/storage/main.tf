# Azure Storage Module - Hardened with Encryption & Access Controls
# Emulates Azure Storage Account with security best practices

terraform {
  required_version = ">= 1.0"
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "resource_group_name" {
  description = "Resource Group name"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "project_name" {
  description = "Project name"
  type        = string
}

variable "storage_tier" {
  description = "Storage tier (Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "enable_encryption" {
  description = "Enable encryption at rest"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable backup and versioning"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Generate unique storage account name
resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

# Simulate Azure Storage Account
resource "null_resource" "storage_account" {
  triggers = {
    name                           = "${var.project_name}storage${random_string.storage_suffix.result}"
    environment                    = var.environment
    location                       = var.location
    resource_group                 = var.resource_group_name
    tier                           = var.storage_tier
    encryption_algorithm           = "AES-256"
    encryption_scope               = "Microsoft-managed"
    https_traffic_only             = true
    min_tls_version                = "TLS1_2"
    shared_access_signature_expiry = "90 days"
    network_default_rule           = "Deny"
    backup_retention_days          = var.enable_backup ? 30 : 0
  }

  provisioner "local-exec" {
    command = "echo 'Creating Storage Account: ${self.triggers.name} with encryption ${self.triggers.encryption_algorithm}'"
  }

  lifecycle {
    ignore_changes = [triggers["name"]]
  }
}

# Simulate Blob Storage Container
resource "null_resource" "blob_container" {
  count = 3

  triggers = {
    name                    = "${var.project_name}-container-${count.index}-${var.environment}"
    storage_account_name    = null_resource.storage_account.triggers.name
    access_type             = "Private"
    immutable_storage       = true
    versioning_enabled      = var.enable_backup
    soft_delete_enabled     = true
    soft_delete_days        = 7
    point_in_time_restore   = var.enable_backup
  }

  provisioner "local-exec" {
    command = "echo 'Creating Blob Container: ${self.triggers.name} with access control: ${self.triggers.access_type}'"
  }

  depends_on = [null_resource.storage_account]
}

# Simulate Azure Key Vault for secret management
resource "null_resource" "key_vault" {
  triggers = {
    name                    = "${var.project_name}-kv-${var.environment}"
    resource_group          = var.resource_group_name
    location                = var.location
    sku                     = "premium"
    enable_purge_protection = true
    soft_delete_enabled     = true
    enable_rbac             = true
    network_rules           = "Default: Deny, Allow: VirtualNetwork"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Key Vault: ${self.triggers.name} with purge protection and RBAC enabled'"
  }
}

# Simulate Key Vault Secrets for storage credentials
resource "null_resource" "storage_secrets" {
  count = 2

  triggers = {
    name               = "storage-secret-${count.index}"
    key_vault_name     = null_resource.key_vault.triggers.name
    secret_value       = "encrypted-secret-value-${count.index}"
    expires_in_days    = 365
    auto_rotate        = true
    content_type       = "application/json"
  }

  provisioner "local-exec" {
    command = "echo 'Storing secret: ${self.triggers.name} in Key Vault'"
  }

  depends_on = [null_resource.key_vault]
}

output "storage_account_name" {
  description = "Storage Account name"
  value       = null_resource.storage_account.triggers.name
}

output "storage_account_ids" {
  description = "Map of storage account names to IDs"
  value = {
    data = "storage-data-${var.environment}-${random_string.storage_suffix.result}"
    diag = "storage-diag-${var.environment}-${random_string.storage_suffix.result}"
  }
}

output "diagnostics_storage_endpoint" {
  description = "Diagnostics storage blob endpoint"
  value       = "https://stdiag${var.environment}${random_string.storage_suffix.result}.blob.core.windows.net"
}

output "diagnostics_storage_id" {
  description = "Diagnostics storage account ID"
  value       = "storage-diag-${var.environment}-${random_string.storage_suffix.result}"
}

output "backup_container_url" {
  description = "Backup container URL"
  value       = "https://stdata${var.environment}${random_string.storage_suffix.result}.blob.core.windows.net/backups"
}

output "blob_container_names" {
  description = "Blob Container names"
  value       = [for container in null_resource.blob_container : container.triggers.name]
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = null_resource.key_vault.triggers.name
}

output "storage_info" {
  description = "Storage infrastructure information"
  value = {
    storage_account     = null_resource.storage_account.triggers.name
    tier                = null_resource.storage_account.triggers.tier
    encryption_enabled  = true
    https_required      = true
    min_tls_version     = "TLS1_2"
    backup_enabled      = var.enable_backup
    backup_retention    = null_resource.storage_account.triggers.backup_retention_days
    containers_count    = length(null_resource.blob_container)
    key_vault_protected = true
    environment         = var.environment
  }
}
