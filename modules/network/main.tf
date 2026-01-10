# Azure Network Module - Hardened VPC/VNET Emulation
# Creates network infrastructure with security controls

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
  description = "Project name for naming conventions"
  type        = string
}

variable "network_cidr" {
  description = "CIDR block for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "enable_encryption" {
  description = "Enable encryption for network traffic"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Generate a unique suffix for resource names
resource "random_string" "network_suffix" {
  length  = 4
  special = false
  upper   = false
}

# Simulate Azure Virtual Network
resource "null_resource" "virtual_network" {
  triggers = {
    name              = "${var.project_name}-vnet-${var.environment}"
    cidr              = var.network_cidr
    region            = var.location
    resource_group    = var.resource_group_name
    encryption        = var.enable_encryption
    ddos_protection   = "enabled"
    dns_servers       = "8.8.8.8,8.8.4.4"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Virtual Network: ${self.triggers.name} with CIDR ${self.triggers.cidr} in ${self.triggers.region}'"
  }
}

# Simulate Azure Subnets
resource "null_resource" "subnets" {
  count = 3

  triggers = {
    name              = "${var.project_name}-subnet-${count.index}-${var.environment}"
    vnet_name         = null_resource.virtual_network.triggers.name
    cidr              = cidrsubnet(var.network_cidr, 3, count.index)
    service_endpoints = "Microsoft.Storage,Microsoft.Sql,Microsoft.EventHub"
    nsg_enabled       = true
  }

  provisioner "local-exec" {
    command = "echo 'Creating Subnet: ${self.triggers.name} with CIDR ${self.triggers.cidr}'"
  }

  depends_on = [null_resource.virtual_network]
}

# Simulate Network Security Groups (NSG) - Firewall Rules
resource "null_resource" "network_security_group" {
  count = 3

  triggers = {
    name                     = "${var.project_name}-nsg-${count.index}-${var.environment}"
    subnet_id                = null_resource.subnets[count.index].triggers.name
    allow_inbound_https      = "443"
    allow_inbound_http       = "80"
    allow_inbound_ssh        = "22"
    deny_inbound_rdp         = "3389"
    outbound_restricted      = true
    threat_protection        = "enabled"
    ddos_protection_plan     = "standard"
  }

  provisioner "local-exec" {
    command = "echo 'Creating NSG: ${self.triggers.name} with threat protection enabled'"
  }

  depends_on = [null_resource.subnets]
}

# Simulate Azure Route Tables for traffic management
resource "null_resource" "route_table" {
  triggers = {
    name              = "${var.project_name}-rt-${var.environment}"
    propagate_routes  = true
    bgp_route_propagation = true
  }

  provisioner "local-exec" {
    command = "echo 'Creating Route Table: ${self.triggers.name}'"
  }

  depends_on = [null_resource.network_security_group]
}

output "virtual_network_id" {
  description = "Virtual Network ID"
  value       = null_resource.virtual_network.triggers.name
}

output "vnet_id" {
  description = "Virtual Network ID"
  value       = "${var.project_name}-vnet-${var.environment}-${random_string.network_suffix.result}"
}

output "vnet_name" {
  description = "Virtual Network name"
  value       = "${var.project_name}-vnet-${var.environment}"
}

output "virtual_network_cidr" {
  description = "Virtual Network CIDR"
  value       = null_resource.virtual_network.triggers.cidr
}

output "subnet_ids" {
  description = "Map of subnet names to IDs"
  value = {
    web  = "${var.project_name}-snet-web-${var.environment}-${random_string.network_suffix.result}"
    app  = "${var.project_name}-snet-app-${var.environment}-${random_string.network_suffix.result}"
    data = "${var.project_name}-snet-data-${var.environment}-${random_string.network_suffix.result}"
    mgmt = "${var.project_name}-snet-mgmt-${var.environment}-${random_string.network_suffix.result}"
  }
}

output "nsg_ids" {
  description = "Map of NSG names to IDs"
  value = {
    web  = "${var.project_name}-nsg-web-${var.environment}-${random_string.network_suffix.result}"
    app  = "${var.project_name}-nsg-app-${var.environment}-${random_string.network_suffix.result}"
    data = "${var.project_name}-nsg-data-${var.environment}-${random_string.network_suffix.result}"
  }
}

output "resource_group_name" {
  description = "Resource Group Name"
  value       = var.resource_group_name
}

output "location" {
  description = "Azure Region"
  value       = var.location
}

output "network_info" {
  description = "Network infrastructure information"
  value = {
    vnet_name          = null_resource.virtual_network.triggers.name
    subnets_count      = length(null_resource.subnets)
    nsgs_count         = length(null_resource.network_security_group)
    encryption_enabled = var.enable_encryption
    ddos_protected     = true
    environment        = var.environment
  }
}
