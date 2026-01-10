# Azure Compute Module - Hardened VM Deployment
# Emulates Azure Virtual Machines with security hardening

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

variable "vm_size" {
  description = "VM size (Standard_B2s, Standard_D2s_v3, etc.)"
  type        = string
  default     = "Standard_B2s"
}

variable "instance_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 2
}

variable "subnet_ids" {
  description = "List of subnet IDs for VM placement"
  type        = list(string)
  default     = []
}

variable "enable_monitoring" {
  description = "Enable Azure Monitor agent"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Simulate Network Interfaces
resource "null_resource" "network_interfaces" {
  count = var.instance_count

  triggers = {
    name                    = "${var.project_name}-nic-${count.index}-${var.environment}"
    resource_group          = var.resource_group_name
    ip_configuration        = "dynamic"
    enable_ip_forwarding    = false
    enable_accelerated_networking = false
    network_security_group  = "${var.project_name}-nsg-${count.index % 3}-${var.environment}"
    private_ip_version      = "IPv4"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Network Interface: ${self.triggers.name}'"
  }
}

# Simulate Azure Virtual Machines
resource "null_resource" "virtual_machines" {
  count = var.instance_count

  triggers = {
    name                             = "${var.project_name}-vm-${count.index}-${var.environment}"
    resource_group                   = var.resource_group_name
    location                         = var.location
    size                             = var.vm_size
    os_type                          = "Linux"
    os_disk_encryption               = "enabled"
    os_disk_encryption_algorithm     = "RSA-2048"
    enable_disk_encryption           = true
    enable_backup                    = true
    enable_monitoring                = var.enable_monitoring
    enable_system_managed_identity   = true
    boot_diagnostic_enabled          = true
    patch_assessment_mode            = "AutomaticByPlatform"
    patch_mode                       = "AutomaticByPlatform"
    hot_patch_enabled                = true
    network_interface_id             = null_resource.network_interfaces[count.index].triggers.name
    public_ip_sku                    = "Standard"
    enable_public_ip                 = (var.environment == "prod" ? false : true)
    nsg_id                           = "${var.project_name}-nsg-${count.index % 3}-${var.environment}"
  }

  provisioner "local-exec" {
    command = "echo 'Creating VM: ${self.triggers.name} with encryption enabled, automatic updates, and monitoring'"
  }

  depends_on = [null_resource.network_interfaces]
}

# Simulate Managed Disks for storage
resource "null_resource" "managed_disks" {
  count = var.instance_count * 2

  triggers = {
    name                       = "${var.project_name}-disk-${count.index}-${var.environment}"
    size_gb                    = count.index % 2 == 0 ? 128 : 256
    storage_account_type       = var.environment == "prod" ? "Premium_LRS" : "Standard_LRS"
    encryption_enabled         = true
    encryption_algorithm       = "AES-256"
    disk_encryption_set        = "${var.project_name}-des-${var.environment}"
    create_option              = "Empty"
    vm_id                      = null_resource.virtual_machines[floor(count.index / 2)].triggers.name
  }

  provisioner "local-exec" {
    command = "echo 'Creating Managed Disk: ${self.triggers.name} with encryption and type: ${self.triggers.storage_account_type}'"
  }

  depends_on = [null_resource.virtual_machines]
}

# Simulate Public IP Addresses (for non-prod)
resource "null_resource" "public_ips" {
  count = var.environment != "prod" ? var.instance_count : 0

  triggers = {
    name              = "${var.project_name}-pip-${count.index}-${var.environment}"
    resource_group    = var.resource_group_name
    location          = var.location
    sku               = "Standard"
    allocation_method = "Static"
    version           = "IPv4"
    idle_timeout      = 4
  }

  provisioner "local-exec" {
    command = "echo 'Creating Public IP: ${self.triggers.name}'"
  }
}

# Simulate Azure Backup for VMs
resource "null_resource" "backup_vault" {
  triggers = {
    name              = "${var.project_name}-backup-${var.environment}"
    resource_group    = var.resource_group_name
    location          = var.location
    storage_redundancy = var.environment == "prod" ? "GeoRedundant" : "LocallyRedundant"
    soft_delete_enabled = true
    cross_region_restore = var.environment == "prod"
    retention_days    = var.environment == "prod" ? 30 : 7
  }

  provisioner "local-exec" {
    command = "echo 'Creating Backup Vault: ${self.triggers.name} with ${self.triggers.storage_redundancy} redundancy'"
  }
}

output "vm_ids" {
  description = "Virtual Machine IDs"
  value       = [for vm in null_resource.virtual_machines : vm.triggers.name]
}

output "nic_ids" {
  description = "Network Interface IDs"
  value       = [for nic in null_resource.network_interfaces : nic.triggers.name]
}

output "public_ip_ids" {
  description = "Public IP IDs (non-prod only)"
  value       = [for pip in null_resource.public_ips : pip.triggers.name]
}

output "compute_info" {
  description = "Compute infrastructure information"
  value = {
    vm_count              = length(null_resource.virtual_machines)
    vm_size               = var.vm_size
    os_type               = "Linux"
    encryption_enabled    = true
    backup_enabled        = true
    monitoring_enabled    = var.enable_monitoring
    managed_identity      = true
    automatic_updates     = true
    backup_retention_days = var.environment == "prod" ? 30 : 7
    disk_encryption_set   = "${var.project_name}-des-${var.environment}"
  }
}
