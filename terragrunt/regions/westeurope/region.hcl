# =============================================================================
# AZURE REGION CONFIGURATION - West Europe
# =============================================================================
# European region with GDPR compliance requirements
#
# Inheritance Chain:
#   1. root.hcl      - Azure provider setup, backend, global settings
#   2. region.hcl    - Azure region-specific (you are here)
#   3. env.hcl       - Environment-specific (dev/staging/prod)
#   4. tier.hcl      - Tier-specific (web/app/data)
#   5. terragrunt.hcl - Module-specific
# =============================================================================

locals {
  # ==========================================================================
  # AZURE REGION IDENTIFICATION
  # ==========================================================================
  region_code          = "weu"
  azure_region         = "westeurope"
  azure_region_display = "West Europe"
  azure_region_pair    = "northeurope"
  
  # DR configuration
  dr_region_code          = "neu"
  dr_azure_region         = "northeurope"
  dr_azure_region_display = "North Europe"
  
  # ==========================================================================
  # AZURE SUBSCRIPTION & TENANT
  # ==========================================================================
  subscription_id = get_env("ARM_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")
  tenant_id       = get_env("ARM_TENANT_ID", "00000000-0000-0000-0000-000000000000")
  
  # ==========================================================================
  # AZURE COMPLIANCE (GDPR Specific)
  # ==========================================================================
  compliance_frameworks = ["SOC2", "GDPR", "ISO27001", "ISO27017", "ISO27018"]
  data_residency        = "EU"
  azure_government      = false
  gdpr_applicable       = true
  
  # GDPR-specific settings
  gdpr_settings = {
    data_retention_days    = 365
    right_to_deletion      = true
    data_portability       = true
    consent_management     = true
    dpo_email              = "dpo@company.com"
    breach_notification_hours = 72
    data_processing_agreement = true
  }
  
  # Azure Policy Initiatives (EU specific)
  azure_policy_initiatives = [
    "Azure Security Benchmark",
    "CIS Microsoft Azure Foundations Benchmark",
    "ISO 27001:2013",
    "GDPR",
  ]
  
  # ==========================================================================
  # AZURE REGIONAL NETWORK TOPOLOGY
  # ==========================================================================
  regional_address_space = "172.16.0.0/12"
  
  environment_address_spaces = {
    dev     = "172.16.0.0/16"
    staging = "172.17.0.0/16"
    prod    = "172.18.0.0/16"
    dr      = "172.19.0.0/16"
  }
  
  vnet_settings = {
    dns_servers           = ["168.63.129.16", "172.16.0.4"]
    enable_ddos_protection = true
    enable_vm_protection   = true
  }
  
  # ==========================================================================
  # AZURE PRIVATE DNS ZONES
  # ==========================================================================
  private_dns_zones = [
    "privatelink.blob.core.windows.net",
    "privatelink.file.core.windows.net",
    "privatelink.queue.core.windows.net",
    "privatelink.table.core.windows.net",
    "privatelink.database.windows.net",
    "privatelink.vaultcore.azure.net",
    "privatelink.azurecr.io",
    "privatelink.servicebus.windows.net",
    "privatelink.eventgrid.azure.net",
  ]
  
  dns_zone_suffix     = "weu.internal.company.com"
  public_dns_zone     = "eu.company.com"
  private_dns_enabled = true
  
  # ==========================================================================
  # AZURE AVAILABILITY ZONES
  # ==========================================================================
  availability_zones     = ["1", "2", "3"]
  primary_az             = "1"
  zone_redundant_enabled = true
  
  zone_distribution = {
    web  = ["1", "2", "3"]
    app  = ["1", "2", "3"]
    data = ["1", "2"]
  }
  
  # ==========================================================================
  # AZURE SERVICE ENDPOINTS
  # ==========================================================================
  service_endpoints = [
    "Microsoft.Storage",
    "Microsoft.Sql",
    "Microsoft.KeyVault",
    "Microsoft.EventHub",
    "Microsoft.ServiceBus",
    "Microsoft.ContainerRegistry",
    "Microsoft.AzureActiveDirectory",
    "Microsoft.AzureCosmosDB",
    "Microsoft.Web",
  ]
  
  private_endpoint_network_policies_enabled = false
  private_link_service_network_policies_enabled = false
  
  # ==========================================================================
  # AZURE COST MANAGEMENT
  # ==========================================================================
  cost_center_codes = {
    infrastructure = "INFRA-WEU-001"
    networking     = "NET-WEU-001"
    security       = "SEC-WEU-001"
    data           = "DATA-WEU-001"
    compute        = "COMP-WEU-001"
    monitoring     = "MON-WEU-001"
  }
  
  budget_alerts = {
    dev     = 4000   # EUR
    staging = 8000
    prod    = 40000
  }
  
  # ==========================================================================
  # AZURE KEY VAULT & ENCRYPTION
  # ==========================================================================
  regional_key_vault_name = "kv-regional-weu-001"
  
  key_vault_settings = {
    sku_name                  = "premium"
    soft_delete_retention_days = 90
    purge_protection_enabled   = true
    enable_rbac_authorization  = true
  }
  
  encryption_settings = {
    enable_cmk              = true
    key_type                = "RSA"
    key_size                = 4096
    key_rotation_days       = 30  # Shorter rotation for GDPR
    enable_double_encryption = true
  }
  
  disk_encryption_set_name = "des-regional-weu-001"
  
  # ==========================================================================
  # AZURE MONITOR & LOG ANALYTICS
  # ==========================================================================
  log_analytics_workspace = {
    name                       = "law-regional-weu-001"
    sku                        = "PerGB2018"
    retention_in_days          = 365  # GDPR requires longer retention
    daily_quota_gb             = 10
    internet_ingestion_enabled = false
    internet_query_enabled     = false
  }
  
  application_insights_type = "web"
  
  diagnostic_categories = {
    logs = [
      "Administrative",
      "Security",
      "ServiceHealth",
      "Alert",
      "Recommendation",
      "Policy",
      "Autoscale",
      "ResourceHealth",
    ]
    metrics = ["AllMetrics"]
  }
  
  # ==========================================================================
  # AZURE DEFENDER & SECURITY CENTER
  # ==========================================================================
  defender_plans = {
    virtual_machines      = true
    storage_accounts      = true
    sql_servers           = true
    key_vaults            = true
    dns                   = true
    arm                   = true
    container_registry    = true
    kubernetes            = true
  }
  
  security_contact = {
    email               = "security-weu@company.com"
    phone               = "+44-555-0100"
    alert_notifications = true
    alerts_to_admins    = true
  }
  
  # ==========================================================================
  # AZURE BACKUP & DISASTER RECOVERY
  # ==========================================================================
  recovery_services_vault = {
    name                         = "rsv-regional-weu-001"
    sku                          = "Standard"
    soft_delete_enabled          = true
    storage_mode_type            = "GeoRedundant"
    cross_region_restore_enabled = true
  }
  
  site_recovery_enabled = true
  site_recovery_target_region = "northeurope"
  
  # ==========================================================================
  # AZURE RESOURCE LIMITS
  # ==========================================================================
  resource_limits = {
    max_vnets_per_subscription    = 1000
    max_subnets_per_vnet          = 3000
    max_nsg_rules_per_nsg         = 1000
    max_route_tables_per_subscription = 200
    max_routes_per_route_table    = 400
    max_peerings_per_vnet         = 500
  }
  
  # ==========================================================================
  # AZURE REGIONAL TAGS
  # ==========================================================================
  regional_tags = {
    azure_region         = local.azure_region
    azure_region_display = local.azure_region_display
    azure_region_pair    = local.azure_region_pair
    data_residency       = local.data_residency
    compliance           = join(",", local.compliance_frameworks)
    dr_region            = local.dr_azure_region
    gdpr_applicable      = tostring(local.gdpr_applicable)
    cost_center          = local.cost_center_codes.infrastructure
    managed_by           = "terragrunt"
    iac_version          = "2.0"
  }
  
  # ==========================================================================
  # AZURE NAMING CONVENTIONS
  # ==========================================================================
  naming_prefix = "cmp-${local.region_code}"
  
  resource_abbreviations = {
    resource_group       = "rg"
    virtual_network      = "vnet"
    subnet               = "snet"
    network_security_group = "nsg"
    route_table          = "rt"
    public_ip            = "pip"
    load_balancer        = "lb"
    application_gateway  = "agw"
    virtual_machine      = "vm"
    availability_set     = "avail"
    storage_account      = "st"
    key_vault            = "kv"
    log_analytics        = "law"
    application_insights = "appi"
    sql_server           = "sql"
    sql_database         = "sqldb"
    cosmos_db            = "cosmos"
    container_registry   = "acr"
    kubernetes_cluster   = "aks"
  }
}
