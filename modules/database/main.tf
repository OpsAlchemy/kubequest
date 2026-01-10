# Azure Database Module - Hardened SQL Database
# Emulates Azure SQL Database with encryption, backups, and compliance

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

variable "database_tier" {
  description = "Database tier (Basic, Standard, Premium)"
  type        = string
  default     = "Standard"
}

variable "enable_encryption" {
  description = "Enable Transparent Data Encryption (TDE)"
  type        = bool
  default     = true
}

variable "enable_backup" {
  description = "Enable automated backups"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Generate unique SQL server name
resource "random_string" "sql_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Simulate Azure SQL Server
resource "null_resource" "sql_server" {
  triggers = {
    name                              = "${var.project_name}-sqlserver-${random_string.sql_suffix.result}"
    resource_group                    = var.resource_group_name
    location                          = var.location
    version                           = "12.0"
    admin_login                       = "sqladmin"
    password_policy                   = "enforced"
    enable_transparent_data_encryption = var.enable_encryption
    threat_detection_enabled          = true
    vulnerability_scanning            = true
    enable_auditing                   = true
    audit_retention_days              = var.environment == "prod" ? 90 : 30
    managed_identity_enabled          = true
    public_endpoint_enabled           = var.environment != "prod"
    firewall_default_action           = "Deny"
    allow_azure_services              = true
  }

  provisioner "local-exec" {
    command = "echo 'Creating SQL Server: ${self.triggers.name} with TDE and threat detection enabled'"
  }

  lifecycle {
    ignore_changes = [triggers["name"]]
  }
}

# Simulate Azure SQL Database
resource "null_resource" "sql_database" {
  count = 2

  triggers = {
    name                         = "${var.project_name}-db-${count.index}-${var.environment}"
    server_name                  = null_resource.sql_server.triggers.name
    resource_group               = var.resource_group_name
    location                     = var.location
    edition                      = var.database_tier
    service_objective_name       = var.environment == "prod" ? "S2" : "S1"
    transparent_data_encryption  = var.enable_encryption
    encryption_algorithm         = "AES-256"
    key_rotation_period_days     = 90
    backup_retention_days        = var.enable_backup ? (var.environment == "prod" ? 35 : 7) : 0
    long_term_retention_enabled  = var.environment == "prod"
    long_term_retention_weeks    = var.environment == "prod" ? 12 : 0
    geo_replication_enabled      = var.environment == "prod"
    geo_replication_region       = var.environment == "prod" ? "East US 2" : ""
    collation                    = "SQL_Latin1_General_CP1_CI_AS"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Database: ${self.triggers.name} with TDE, ${self.triggers.backup_retention_days}-day retention, and geo-replication: ${self.triggers.geo_replication_enabled}'"
  }

  depends_on = [null_resource.sql_server]
}

# Simulate SQL Database Firewall Rules
resource "null_resource" "firewall_rules" {
  count = 2

  triggers = {
    name              = "${var.project_name}-fwrule-${count.index}-${var.environment}"
    server_name       = null_resource.sql_server.triggers.name
    start_ip_address  = count.index == 0 ? "10.0.0.0" : "192.168.0.0"
    end_ip_address    = count.index == 0 ? "10.255.255.255" : "192.168.255.255"
    rule_purpose      = count.index == 0 ? "Internal Network Access" : "VPN Access"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Firewall Rule: ${self.triggers.name} (${self.triggers.start_ip_address} - ${self.triggers.end_ip_address})'"
  }

  depends_on = [null_resource.sql_server]
}

# Simulate Advanced Data Security / Threat Protection
resource "null_resource" "advanced_threat_protection" {
  triggers = {
    server_name              = null_resource.sql_server.triggers.name
    threat_detection_enabled = true
    vulnerability_scanning   = true
    data_discovery_enabled   = true
    confidential_data_types  = "PII,PHI,Financial Data"
  }

  provisioner "local-exec" {
    command = "echo 'Enabling Advanced Threat Protection on ${self.triggers.server_name} with data discovery for: ${self.triggers.confidential_data_types}'"
  }

  depends_on = [null_resource.sql_server]
}

# Simulate Transparent Data Encryption (TDE)
resource "null_resource" "tde_configuration" {
  triggers = {
    server_name          = null_resource.sql_server.triggers.name
    encryption_enabled   = var.enable_encryption
    algorithm            = "AES256"
    key_vault_key_id     = "${var.project_name}-tde-key-${var.environment}"
    auto_rotation        = true
    rotation_period_days = 90
  }

  provisioner "local-exec" {
    command = "echo 'Configuring TDE on ${self.triggers.server_name} with key vault and auto-rotation every ${self.triggers.rotation_period_days} days'"
  }

  depends_on = [null_resource.sql_server]
}

output "sql_server_name" {
  description = "SQL Server name"
  value       = null_resource.sql_server.triggers.name
}

output "sql_server_id" {
  description = "SQL Server ID"
  value       = "sql-server-${var.environment}-${random_string.sql_suffix.result}"
}

output "sql_database_ids" {
  description = "Map of database names to IDs"
  value = {
    app   = "sqldb-app-${var.environment}-${random_string.sql_suffix.result}"
    audit = "sqldb-audit-${var.environment}-${random_string.sql_suffix.result}"
  }
}

output "cosmosdb_id" {
  description = "Cosmos DB account ID (null if not enabled)"
  value       = var.environment != "dev" ? "cosmos-${var.environment}-${random_string.sql_suffix.result}" : null
}

output "redis_id" {
  description = "Redis Cache ID"
  value       = "redis-${var.environment}-${random_string.sql_suffix.result}"
}

output "database_names" {
  description = "Database names"
  value       = [for db in null_resource.sql_database : db.triggers.name]
}

output "firewall_rule_names" {
  description = "Firewall rule names"
  value       = [for rule in null_resource.firewall_rules : rule.triggers.name]
}

output "database_info" {
  description = "Database infrastructure information"
  value = {
    server_name             = null_resource.sql_server.triggers.name
    database_count          = length(null_resource.sql_database)
    tier                    = var.database_tier
    encryption_enabled      = var.enable_encryption
    tde_enabled             = var.enable_encryption
    backup_enabled          = var.enable_backup
    backup_retention_days   = var.environment == "prod" ? 35 : 7
    geo_replication         = var.environment == "prod"
    threat_detection        = true
    vulnerability_scanning  = true
    audit_logging_days      = var.environment == "prod" ? 90 : 30
    environment             = var.environment
  }
}
