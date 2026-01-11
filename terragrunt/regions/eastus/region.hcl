# =============================================================================
# AZURE REGION CONFIGURATION - East US
# =============================================================================
# This file defines Azure region-specific configurations that apply to ALL 
# environments within this region. Part of the 5-layer configuration hierarchy:
#
#   root.hcl → region.hcl → env.hcl → tier.hcl → terragrunt.hcl
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
  region_code          = "eus"  # East US abbreviated
  azure_region         = "eastus"
  azure_region_display = "East US"
  azure_region_pair    = "westus"  # Azure paired region for DR
  
  # Geographic redundancy pair (for DR)
  dr_region_code          = "wus"
  dr_azure_region         = "westus"
  dr_azure_region_display = "West US"
  
  # ==========================================================================
  # AZURE SUBSCRIPTION & TENANT
  # ==========================================================================
  # These should be overridden via environment variables in production
  subscription_id = get_env("ARM_SUBSCRIPTION_ID", "00000000-0000-0000-0000-000000000000")
  tenant_id       = get_env("ARM_TENANT_ID", "00000000-0000-0000-0000-000000000000")
  
  # ==========================================================================
  # AZURE COMPLIANCE REQUIREMENTS
  # ==========================================================================
  compliance_frameworks = ["SOC2", "HIPAA", "PCI-DSS", "FedRAMP"]
  data_residency        = "US"
  azure_government      = false
  gdpr_applicable       = false
  
  # Azure Policy Initiatives to enforce
  azure_policy_initiatives = [
    "Azure Security Benchmark",
    "CIS Microsoft Azure Foundations Benchmark",
    "NIST SP 800-53 Rev. 5",
  ]
  
  # ==========================================================================
  # AZURE REGIONAL NETWORK TOPOLOGY
  # ==========================================================================
  # Super-CIDR for entire region (all environments carved from this)
  regional_address_space = "10.0.0.0/8"
  
  # Environment CIDR allocations within region
  environment_address_spaces = {
    dev     = "10.0.0.0/16"
    staging = "10.1.0.0/16"
    prod    = "10.2.0.0/16"
    dr      = "10.3.0.0/16"
  }
  
  # Azure Virtual Network specific settings
  vnet_settings = {
    dns_servers           = ["168.63.129.16", "10.0.0.4"]  # Azure DNS + Custom
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
  
  dns_zone_suffix     = "eus.internal.company.com"
  public_dns_zone     = "eus.company.com"
  private_dns_enabled = true
  
  # ==========================================================================
  # AZURE AVAILABILITY ZONES
  # ==========================================================================
  availability_zones     = ["1", "2", "3"]
  primary_az             = "1"
  zone_redundant_enabled = true
  
  # Zone mapping for resources
  zone_distribution = {
    web  = ["1", "2", "3"]
    app  = ["1", "2", "3"]
    data = ["1", "2"]  # Data tier only in 2 zones for cost
  }
  
  # ==========================================================================
  # AZURE SERVICE ENDPOINTS & PRIVATE ENDPOINTS
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
  
  # Private endpoint configurations
  private_endpoint_network_policies_enabled = false
  private_link_service_network_policies_enabled = false
  
  # ==========================================================================
  # AZURE COST MANAGEMENT
  # ==========================================================================
  cost_center_codes = {
    infrastructure = "INFRA-EUS-001"
    networking     = "NET-EUS-001"
    security       = "SEC-EUS-001"
    data           = "DATA-EUS-001"
    compute        = "COMP-EUS-001"
    monitoring     = "MON-EUS-001"
  }
  
  # Budget alerts (monthly in USD)
  budget_alerts = {
    dev     = 5000
    staging = 10000
    prod    = 50000
  }
  
  # ==========================================================================
  # AZURE KEY VAULT & ENCRYPTION
  # ==========================================================================
  # Regional Key Vault for CMK (Customer Managed Keys)
  regional_key_vault_name = "kv-regional-eus-001"
  
  key_vault_settings = {
    sku_name                  = "premium"  # HSM-backed keys
    soft_delete_retention_days = 90
    purge_protection_enabled   = true
    enable_rbac_authorization  = true
  }
  
  # Encryption settings
  encryption_settings = {
    enable_cmk              = true
    key_type                = "RSA"
    key_size                = 4096
    key_rotation_days       = 90
    enable_double_encryption = true  # Infrastructure encryption
  }
  
  # Disk Encryption Set for VMs
  disk_encryption_set_name = "des-regional-eus-001"
  
  # ==========================================================================
  # AZURE MONITOR & LOG ANALYTICS
  # ==========================================================================
  log_analytics_workspace = {
    name                       = "law-regional-eus-001"
    sku                        = "PerGB2018"
    retention_in_days          = 90
    daily_quota_gb             = 10
    internet_ingestion_enabled = false
    internet_query_enabled     = false
  }
  
  # Application Insights
  application_insights_type = "web"
  
  # Diagnostic settings categories
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
    arm                   = true  # Azure Resource Manager
    container_registry    = true
    kubernetes            = true
  }
  
  security_contact = {
    email               = "security-eus@company.com"
    phone               = "+1-555-0100"
    alert_notifications = true
    alerts_to_admins    = true
  }
  
  # ==========================================================================
  # AZURE BACKUP & DISASTER RECOVERY
  # ==========================================================================
  recovery_services_vault = {
    name                         = "rsv-regional-eus-001"
    sku                          = "Standard"
    soft_delete_enabled          = true
    storage_mode_type            = "GeoRedundant"
    cross_region_restore_enabled = true
  }
  
  # Site Recovery for DR
  site_recovery_enabled = true
  site_recovery_target_region = "westus"
  
  # ==========================================================================
  # AZURE RESOURCE LIMITS (Regional)
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
    azure_region        = local.azure_region
    azure_region_display = local.azure_region_display
    azure_region_pair   = local.azure_region_pair
    data_residency      = local.data_residency
    compliance          = join(",", local.compliance_frameworks)
    dr_region           = local.dr_azure_region
    cost_center         = local.cost_center_codes.infrastructure
    managed_by          = "terragrunt"
    iac_version         = "2.0"
  }
  
  # ==========================================================================
  # AZURE NAMING CONVENTIONS
  # ==========================================================================
  # Resource naming prefix: {company}-{region}-{env}-{tier}-{resource}
  naming_prefix = "cmp-${local.region_code}"
  
  # Resource abbreviations (Azure CAF naming)
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
