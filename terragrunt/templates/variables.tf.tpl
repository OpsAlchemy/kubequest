# =============================================================================
# AZURE VARIABLES TEMPLATE
# =============================================================================
# This template auto-generates variables.tf based on the module type
# and environment configuration.
#
# Template Variables:
#   - module_type: network, compute, storage, database, monitoring
#   - environment: dev, staging, prod
#   - tier: web, app, data
# =============================================================================

# =============================================================================
# COMMON VARIABLES (All Modules)
# =============================================================================

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod", "dr"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, dr."
  }
}

variable "azure_region" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "${default_azure_region}"
  
  validation {
    condition     = can(regex("^(eastus|westus|westeurope|northeurope|eastasia|southeastasia)$", var.azure_region))
    error_message = "Azure region must be a valid Azure region name."
  }
}

variable "resource_group_name" {
  description = "Name of the Azure resource group"
  type        = string
  
  validation {
    condition     = can(regex("^[a-zA-Z0-9-_]+$", var.resource_group_name))
    error_message = "Resource group name can only contain alphanumeric characters, hyphens, and underscores."
  }
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "${default_project_name}"
}

variable "tier" {
  description = "Application tier (web, app, data)"
  type        = string
  default     = "${default_tier}"
  
  validation {
    condition     = contains(["web", "app", "data", "mgmt"], var.tier)
    error_message = "Tier must be one of: web, app, data, mgmt."
  }
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

# =============================================================================
# SECURITY VARIABLES
# =============================================================================

variable "enable_encryption" {
  description = "Enable encryption at rest for all resources"
  type        = bool
  default     = true
}

variable "enable_cmk" {
  description = "Enable customer-managed keys for encryption"
  type        = bool
  default     = ${default_enable_cmk}
}

variable "key_vault_id" {
  description = "Azure Key Vault ID for CMK encryption"
  type        = string
  default     = null
}

variable "enable_private_endpoints" {
  description = "Enable private endpoints for Azure services"
  type        = bool
  default     = ${default_enable_private_endpoints}
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access resources"
  type        = list(string)
  default     = []
}

# =============================================================================
# MONITORING VARIABLES
# =============================================================================

variable "enable_monitoring" {
  description = "Enable Azure Monitor and diagnostics"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days to retain logs"
  type        = number
  default     = ${default_log_retention_days}
  
  validation {
    condition     = var.log_retention_days >= 7 && var.log_retention_days <= 365
    error_message = "Log retention must be between 7 and 365 days."
  }
}

variable "enable_alerts" {
  description = "Enable metric and log alerts"
  type        = bool
  default     = true
}

variable "alert_action_group_id" {
  description = "Action group ID for alert notifications"
  type        = string
  default     = null
}

# =============================================================================
# BACKUP & DR VARIABLES
# =============================================================================

variable "enable_backup" {
  description = "Enable Azure Backup for supported resources"
  type        = bool
  default     = true
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = ${default_backup_retention_days}
}

variable "enable_geo_redundancy" {
  description = "Enable geo-redundant storage/replication"
  type        = bool
  default     = ${default_enable_geo_redundancy}
}

variable "enable_dr" {
  description = "Enable disaster recovery configuration"
  type        = bool
  default     = ${default_enable_dr}
}

variable "dr_region" {
  description = "Azure region for disaster recovery"
  type        = string
  default     = "${default_dr_region}"
}

%{ if module_type == "network" ~}
# =============================================================================
# NETWORK MODULE SPECIFIC VARIABLES
# =============================================================================

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = list(string)
  
  validation {
    condition     = alltrue([for cidr in var.vnet_address_space : can(cidrhost(cidr, 0))])
    error_message = "All address spaces must be valid CIDR blocks."
  }
}

variable "subnets" {
  description = "Map of subnet configurations"
  type = map(object({
    address_prefixes                          = list(string)
    service_endpoints                         = optional(list(string), [])
    private_endpoint_network_policies_enabled = optional(bool, true)
    delegation                                = optional(object({
      name = string
      service_delegation = object({
        name    = string
        actions = list(string)
      })
    }))
  }))
}

variable "enable_ddos_protection" {
  description = "Enable DDoS Protection Standard"
  type        = bool
  default     = ${default_enable_ddos}
}

variable "dns_servers" {
  description = "Custom DNS servers for the VNet"
  type        = list(string)
  default     = []
}

variable "enable_bastion" {
  description = "Enable Azure Bastion for secure VM access"
  type        = bool
  default     = ${default_enable_bastion}
}

variable "enable_vpn_gateway" {
  description = "Enable VPN Gateway for hybrid connectivity"
  type        = bool
  default     = false
}

variable "enable_expressroute" {
  description = "Enable ExpressRoute Gateway"
  type        = bool
  default     = false
}
%{ endif ~}

%{ if module_type == "compute" ~}
# =============================================================================
# COMPUTE MODULE SPECIFIC VARIABLES
# =============================================================================

variable "vm_size" {
  description = "Azure VM size"
  type        = string
  default     = "${default_vm_size}"
  
  validation {
    condition     = can(regex("^Standard_", var.vm_size))
    error_message = "VM size must be a valid Azure VM size starting with 'Standard_'."
  }
}

variable "instance_count" {
  description = "Number of VM instances to create"
  type        = number
  default     = ${default_instance_count}
  
  validation {
    condition     = var.instance_count >= 1 && var.instance_count <= 100
    error_message = "Instance count must be between 1 and 100."
  }
}

variable "os_type" {
  description = "Operating system type (linux, windows)"
  type        = string
  default     = "linux"
  
  validation {
    condition     = contains(["linux", "windows"], var.os_type)
    error_message = "OS type must be either 'linux' or 'windows'."
  }
}

variable "os_disk_type" {
  description = "OS disk storage type"
  type        = string
  default     = "Premium_LRS"
  
  validation {
    condition     = contains(["Standard_LRS", "StandardSSD_LRS", "Premium_LRS", "UltraSSD_LRS"], var.os_disk_type)
    error_message = "OS disk type must be a valid Azure managed disk type."
  }
}

variable "os_disk_size_gb" {
  description = "OS disk size in GB"
  type        = number
  default     = 128
}

variable "data_disks" {
  description = "Configuration for data disks"
  type = list(object({
    lun                  = number
    disk_size_gb         = number
    storage_account_type = string
    caching              = optional(string, "ReadOnly")
  }))
  default = []
}

variable "availability_zones" {
  description = "Availability zones for VM deployment"
  type        = list(string)
  default     = ${default_availability_zones}
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on NICs"
  type        = bool
  default     = true
}

variable "enable_boot_diagnostics" {
  description = "Enable boot diagnostics"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "azureuser"
  sensitive   = true
}

variable "enable_auto_shutdown" {
  description = "Enable auto-shutdown for cost savings"
  type        = bool
  default     = ${default_enable_auto_shutdown}
}

variable "auto_shutdown_time" {
  description = "Time to auto-shutdown VMs (24-hour format)"
  type        = string
  default     = "1900"
}
%{ endif ~}

%{ if module_type == "storage" ~}
# =============================================================================
# STORAGE MODULE SPECIFIC VARIABLES
# =============================================================================

variable "account_tier" {
  description = "Storage account tier"
  type        = string
  default     = "${default_storage_tier}"
  
  validation {
    condition     = contains(["Standard", "Premium"], var.account_tier)
    error_message = "Account tier must be 'Standard' or 'Premium'."
  }
}

variable "account_replication_type" {
  description = "Storage replication type"
  type        = string
  default     = "${default_replication_type}"
  
  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "RAGRS", "GZRS", "RAGZRS"], var.account_replication_type)
    error_message = "Replication type must be a valid Azure storage replication type."
  }
}

variable "account_kind" {
  description = "Storage account kind"
  type        = string
  default     = "StorageV2"
}

variable "enable_hns" {
  description = "Enable hierarchical namespace (Data Lake Storage Gen2)"
  type        = bool
  default     = false
}

variable "blob_containers" {
  description = "Map of blob containers to create"
  type = map(object({
    access_type = optional(string, "private")
  }))
  default = {}
}

variable "file_shares" {
  description = "Map of file shares to create"
  type = map(object({
    quota = number
    tier  = optional(string, "Hot")
  }))
  default = {}
}

variable "enable_blob_versioning" {
  description = "Enable blob versioning"
  type        = bool
  default     = true
}

variable "blob_delete_retention_days" {
  description = "Days to retain deleted blobs"
  type        = number
  default     = 30
}

variable "enable_static_website" {
  description = "Enable static website hosting"
  type        = bool
  default     = false
}
%{ endif ~}

%{ if module_type == "database" ~}
# =============================================================================
# DATABASE MODULE SPECIFIC VARIABLES
# =============================================================================

variable "database_type" {
  description = "Database type (sql, postgresql, mysql, cosmosdb)"
  type        = string
  default     = "sql"
  
  validation {
    condition     = contains(["sql", "postgresql", "mysql", "cosmosdb"], var.database_type)
    error_message = "Database type must be one of: sql, postgresql, mysql, cosmosdb."
  }
}

variable "sku_name" {
  description = "Database SKU name"
  type        = string
  default     = "${default_database_sku}"
}

variable "storage_mb" {
  description = "Database storage size in MB"
  type        = number
  default     = 32768
}

variable "administrator_login" {
  description = "Database administrator login name"
  type        = string
  sensitive   = true
}

variable "enable_tde" {
  description = "Enable Transparent Data Encryption"
  type        = bool
  default     = true
}

variable "enable_threat_detection" {
  description = "Enable Advanced Threat Protection"
  type        = bool
  default     = ${default_enable_threat_detection}
}

variable "enable_auditing" {
  description = "Enable database auditing"
  type        = bool
  default     = true
}

variable "pitr_retention_days" {
  description = "Point-in-time restore retention in days"
  type        = number
  default     = ${default_pitr_retention}
}

variable "enable_read_replica" {
  description = "Enable read replica in DR region"
  type        = bool
  default     = ${default_enable_read_replica}
}

variable "firewall_rules" {
  description = "Map of firewall rules"
  type = map(object({
    start_ip_address = string
    end_ip_address   = string
  }))
  default = {}
}

variable "connection_strings" {
  description = "Additional connection strings for the database"
  type        = map(string)
  default     = {}
  sensitive   = true
}
%{ endif ~}

%{ if module_type == "monitoring" ~}
# =============================================================================
# MONITORING MODULE SPECIFIC VARIABLES
# =============================================================================

variable "workspace_sku" {
  description = "Log Analytics Workspace SKU"
  type        = string
  default     = "PerGB2018"
}

variable "daily_quota_gb" {
  description = "Daily ingestion quota in GB"
  type        = number
  default     = ${default_daily_quota}
}

variable "enable_app_insights" {
  description = "Enable Application Insights"
  type        = bool
  default     = true
}

variable "app_insights_type" {
  description = "Application Insights application type"
  type        = string
  default     = "web"
}

variable "enable_sentinel" {
  description = "Enable Microsoft Sentinel"
  type        = bool
  default     = ${default_enable_sentinel}
}

variable "alert_rules" {
  description = "Map of alert rule configurations"
  type = map(object({
    description         = string
    severity            = number
    frequency           = string
    time_window         = string
    query               = optional(string)
    metric_name         = optional(string)
    metric_namespace    = optional(string)
    operator            = string
    threshold           = number
    aggregation         = string
    resource_type       = optional(string)
    auto_mitigation     = optional(bool, false)
  }))
  default = {}
}

variable "action_groups" {
  description = "Map of action group configurations"
  type = map(object({
    short_name = string
    email_receivers = optional(list(object({
      name          = string
      email_address = string
    })), [])
    sms_receivers = optional(list(object({
      name         = string
      country_code = string
      phone_number = string
    })), [])
    webhook_receivers = optional(list(object({
      name        = string
      service_uri = string
    })), [])
  }))
  default = {}
}

variable "diagnostic_settings" {
  description = "Diagnostic settings configuration"
  type = object({
    logs = list(object({
      category = string
      enabled  = bool
      retention_policy = optional(object({
        enabled = bool
        days    = number
      }))
    }))
    metrics = list(object({
      category = string
      enabled  = bool
      retention_policy = optional(object({
        enabled = bool
        days    = number
      }))
    }))
  })
  default = null
}
%{ endif ~}
