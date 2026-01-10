# Azure Monitoring Module - Hardened Observability & Alerting
# Emulates Azure Monitor with logs, metrics, and intelligent alerting

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

variable "enable_monitoring" {
  description = "Enable monitoring"
  type        = bool
  default     = true
}

variable "common_tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

# Generate unique suffix for resource names
resource "random_string" "monitoring_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Simulate Log Analytics Workspace
resource "null_resource" "log_analytics_workspace" {
  triggers = {
    name                 = "${var.project_name}-law-${var.environment}"
    resource_group       = var.resource_group_name
    location             = var.location
    sku                  = var.environment == "prod" ? "PerGB2018" : "Free"
    data_retention_days  = var.environment == "prod" ? 90 : 30
    daily_quota_gb       = var.environment == "prod" ? 10 : 1
    immutable_storage    = var.environment == "prod"
    cmk_encryption       = var.environment == "prod"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Log Analytics Workspace: ${self.triggers.name} with ${self.triggers.data_retention_days}-day retention'"
  }
}

# Simulate Application Insights for APM
resource "null_resource" "application_insights" {
  triggers = {
    name                      = "${var.project_name}-ai-${var.environment}"
    application_type          = "web"
    workspace_id              = null_resource.log_analytics_workspace.triggers.name
    retention_in_days         = var.environment == "prod" ? 90 : 30
    disable_ip_masking        = true
    enable_query_performance  = true
    enable_alert_correlation  = true
    daily_limit_in_gb         = var.environment == "prod" ? 50 : 10
  }

  provisioner "local-exec" {
    command = "echo 'Creating Application Insights: ${self.triggers.name} for APM with ${self.triggers.retention_in_days}-day retention'"
  }

  depends_on = [null_resource.log_analytics_workspace]
}

# Simulate Diagnostic Settings
resource "null_resource" "diagnostic_settings" {
  count = 5

  triggers = {
    name                  = "${var.project_name}-diag-${count.index}-${var.environment}"
    workspace_name        = null_resource.log_analytics_workspace.triggers.name
    log_category          = ["Administrative", "Security", "ServiceHealth", "Alert", "Recommendation"][count.index]
    metrics_enabled       = true
    logs_retention_days   = var.environment == "prod" ? 90 : 30
  }

  provisioner "local-exec" {
    command = "echo 'Creating Diagnostic Setting for ${self.triggers.log_category} logs'"
  }

  depends_on = [null_resource.log_analytics_workspace]
}

# Simulate Action Groups for Alerts
resource "null_resource" "action_group" {
  count = 2

  triggers = {
    name                = "${var.project_name}-ag-${count.index}-${var.environment}"
    resource_group      = var.resource_group_name
    location            = var.location
    short_name          = "ag${count.index}"
    email_notifications = "ops-team@example.com,security-team@example.com"
    webhook_url         = "https://hooks.slack.com/services/YOUR/WEBHOOK/URL"
  }

  provisioner "local-exec" {
    command = "echo 'Creating Action Group: ${self.triggers.name} with email and webhook notifications'"
  }
}

# Simulate Metric Alerts
resource "null_resource" "metric_alerts" {
  count = 4

  triggers = {
    name                  = "${var.project_name}-alert-${["cpu", "memory", "disk", "network"][count.index]}-${var.environment}"
    resource_group        = var.resource_group_name
    metric_name           = ["Percentage CPU", "Available Memory Bytes", "Disk Write Operations/sec", "Network In Total"][count.index]
    operator              = "GreaterThan"
    threshold             = ["80", "1073741824", "1000", "1000000000"][count.index]
    aggregation           = "Average"
    window_size           = "PT5M"
    evaluation_frequency  = "PT1M"
    severity              = count.index < 2 ? "2" : "3"
    action_group_name     = null_resource.action_group[0].triggers.name
  }

  provisioner "local-exec" {
    command = "echo 'Creating Metric Alert: ${self.triggers.name} (threshold: ${self.triggers.threshold})'"
  }

  depends_on = [null_resource.action_group]
}

# Simulate Log Search Alerts
resource "null_resource" "log_search_alerts" {
  count = 2

  triggers = {
    name                = "${var.project_name}-log-alert-${count.index}-${var.environment}"
    workspace_name      = null_resource.log_analytics_workspace.triggers.name
    query               = count.index == 0 ? "AzureActivity | where OperationName contains 'Delete'" : "SecurityEvent | where EventID == 4688"
    search_trigger_name = ["Suspicious Delete Operations", "Process Execution Events"][count.index]
    frequency_minutes   = 5
    threshold_operator  = "GreaterThan"
    threshold           = 0
  }

  provisioner "local-exec" {
    command = "echo 'Creating Log Alert: ${self.triggers.name}'"
  }

  depends_on = [null_resource.log_analytics_workspace]
}

# Simulate Azure Policy for Compliance
resource "null_resource" "azure_policy" {
  triggers = {
    name                     = "${var.project_name}-policy-${var.environment}"
    policy_type              = "BuiltIn"
    policies                 = "require-encryption,enforce-network-security,require-backup,enforce-tls,require-managed-identity"
    auto_remediation_enabled = true
    compliance_check_frequency = "PT24H"
  }

  provisioner "local-exec" {
    command = "echo 'Applying Azure Policies: ${self.triggers.policies} with auto-remediation enabled'"
  }
}

output "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  value       = null_resource.log_analytics_workspace.triggers.name
}

output "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID"
  value       = "log-${var.environment}-${random_string.monitoring_suffix.result}"
}

output "application_insights_name" {
  description = "Application Insights name"
  value       = null_resource.application_insights.triggers.name
}

output "application_insights_id" {
  description = "Application Insights ID"
  value       = "appi-${var.environment}-${random_string.monitoring_suffix.result}"
}

output "application_insights_key" {
  description = "Application Insights Instrumentation Key"
  value       = "00000000-0000-0000-0000-${random_string.monitoring_suffix.result}"
  sensitive   = true
}

output "action_group_ids" {
  description = "Map of action group names to IDs"
  value = {
    critical = "ag-critical-${var.environment}-${random_string.monitoring_suffix.result}"
    warning  = "ag-warning-${var.environment}-${random_string.monitoring_suffix.result}"
  }
}

output "action_group_names" {
  description = "Action Group names"
  value       = [for ag in null_resource.action_group : ag.triggers.name]
}

output "alert_names" {
  description = "Alert names"
  value       = concat(
    [for alert in null_resource.metric_alerts : alert.triggers.name],
    [for alert in null_resource.log_search_alerts : alert.triggers.name]
  )
}

output "dashboard_url" {
  description = "Azure Portal Dashboard URL"
  value       = "https://portal.azure.com/#dashboard/${var.environment}"
}

output "monitoring_info" {
  description = "Monitoring infrastructure information"
  value = {
    workspace_name           = null_resource.log_analytics_workspace.triggers.name
    app_insights_enabled     = true
    metric_alerts_count      = length(null_resource.metric_alerts)
    log_search_alerts_count  = length(null_resource.log_search_alerts)
    action_groups_count      = length(null_resource.action_group)
    data_retention_days      = var.environment == "prod" ? 90 : 30
    azure_policies_enabled   = true
    auto_remediation         = true
    security_monitoring      = true
    environment              = var.environment
  }
}
