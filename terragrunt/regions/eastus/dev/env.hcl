# =============================================================================
# ENVIRONMENT CONFIGURATION - DEV (US East Region)
# =============================================================================
# Part of the 5-layer configuration hierarchy:
#
#   root.hcl → region.hcl → env.hcl (you are here) → tier.hcl → terragrunt.hcl
#
# This file consumes from:
#   - region.hcl (Azure regional settings)
#
# This file is consumed by:
#   - tier.hcl (Web/App/Data tier settings)
#   - All module terragrunt.hcl files
# =============================================================================

# Load region configuration
locals {
  # ==========================================================================
  # INHERIT FROM REGION
  # ==========================================================================
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  # Inherit region values
  azure_region         = local.region_vars.locals.azure_region
  azure_region_display = local.region_vars.locals.azure_region_display
  region_code          = local.region_vars.locals.region_code
  dr_azure_region      = local.region_vars.locals.dr_azure_region
  
  # Inherit compliance settings
  compliance_frameworks = local.region_vars.locals.compliance_frameworks
  data_residency        = local.region_vars.locals.data_residency
  
  # Inherit network topology
  environment_address_spaces = local.region_vars.locals.environment_address_spaces
  service_endpoints          = local.region_vars.locals.service_endpoints
  private_dns_zones          = local.region_vars.locals.private_dns_zones
  
  # Inherit availability zones
  availability_zones = local.region_vars.locals.availability_zones
  
  # Inherit encryption settings
  encryption_settings = local.region_vars.locals.encryption_settings
  
  # Inherit monitoring settings
  log_analytics_workspace = local.region_vars.locals.log_analytics_workspace
  
  # Inherit naming conventions
  resource_abbreviations = local.region_vars.locals.resource_abbreviations
  
  # ==========================================================================
  # ENVIRONMENT IDENTIFICATION
  # ==========================================================================
  environment       = "dev"
  environment_code  = "d"
  environment_name  = "Development"
  is_production     = false
  
  # ==========================================================================
  # AZURE RESOURCE NAMING
  # ==========================================================================
  # Naming pattern: {company}-{region}-{env}-{tier}-{resource}-{instance}
  # Example: cmp-eus-d-web-vm-001
  naming_prefix       = "cmp-${local.region_code}-${local.environment_code}"
  resource_group_name = "${local.naming_prefix}-rg"
  project_name        = "terragrunt-hardened"
  
  # ==========================================================================
  # AZURE NETWORKING - ENVIRONMENT SPECIFIC
  # ==========================================================================
  network_cidr = local.environment_address_spaces[local.environment]  # 10.0.0.0/16
  
  # Subnet CIDRs (carved from environment CIDR)
  subnet_cidrs = {
    web     = cidrsubnet(local.network_cidr, 8, 0)   # 10.0.0.0/24
    app     = cidrsubnet(local.network_cidr, 7, 1)   # 10.0.2.0/23
    data    = cidrsubnet(local.network_cidr, 8, 4)   # 10.0.4.0/24
    bastion = cidrsubnet(local.network_cidr, 10, 20) # 10.0.5.0/26
    gateway = cidrsubnet(local.network_cidr, 10, 21) # 10.0.5.64/26
    private_endpoints = cidrsubnet(local.network_cidr, 8, 10) # 10.0.10.0/24
  }
  
  # DNS settings
  dns_zone_name = "${local.environment}.${local.region_code}.internal.company.com"
  
  # ==========================================================================
  # AZURE COMPUTE - ENVIRONMENT SPECIFIC
  # ==========================================================================
  # VM sizing (cost-optimized for dev)
  vm_sizes = {
    web  = "Standard_B2s"
    app  = "Standard_B2ms"
    data = "Standard_B2s"
  }
  
  # Instance counts (minimal for dev)
  instance_counts = {
    web  = 1
    app  = 2
    data = 1
  }
  
  # Public IP settings
  enable_public_ips = true  # Enabled for dev
  
  # ==========================================================================
  # AZURE STORAGE - ENVIRONMENT SPECIFIC
  # ==========================================================================
  storage_tier             = "Standard"
  storage_replication_type = "LRS"  # Local redundancy for dev
  
  # ==========================================================================
  # AZURE DATABASE - ENVIRONMENT SPECIFIC
  # ==========================================================================
  database_tier = "S1"  # Standard tier for dev
  database_sku  = "Standard"
  database_dtus = 20
  
  # Backup settings (minimal for dev)
  backup_retention_days      = 7
  geo_redundant_backup       = false
  point_in_time_restore_days = 7
  
  # ==========================================================================
  # AZURE MONITORING - ENVIRONMENT SPECIFIC
  # ==========================================================================
  log_retention_days    = 30
  enable_advanced_monitoring = false
  enable_threat_detection = false  # Cost savings for dev
  
  # Alert settings
  alert_severity_threshold = 2  # Only critical alerts
  enable_pager_alerts      = false
  
  # ==========================================================================
  # AZURE SECURITY - ENVIRONMENT SPECIFIC
  # ==========================================================================
  enable_encryption    = true
  enable_cmk           = false  # No CMK for dev (cost)
  enable_backup        = true
  enable_monitoring    = true
  enable_waf           = false  # No WAF for dev (cost)
  enable_ddos_protection = false  # No DDoS for dev (cost)
  
  # Network security
  allow_public_access    = true   # Allowed for dev
  enable_private_endpoints = false  # Cost savings
  
  # ==========================================================================
  # AZURE DISASTER RECOVERY - ENVIRONMENT SPECIFIC
  # ==========================================================================
  enable_dr             = false  # No DR for dev
  enable_geo_replication = false
  
  # ==========================================================================
  # AZURE COST MANAGEMENT
  # ==========================================================================
  cost_center = "DEV-${upper(local.region_code)}-001"
  budget_amount = 5000  # Monthly budget in USD
  
  # Auto-shutdown for cost savings
  auto_shutdown_enabled = true
  auto_shutdown_time    = "1900"  # 7 PM
  auto_shutdown_timezone = "Eastern Standard Time"
  
  # ==========================================================================
  # ENVIRONMENT TAGS
  # ==========================================================================
  environment_tags = {
    environment      = local.environment
    environment_name = local.environment_name
    is_production    = tostring(local.is_production)
    cost_center      = local.cost_center
    auto_shutdown    = tostring(local.auto_shutdown_enabled)
  }
  
  # Merge with regional tags
  common_tags = merge(
    local.region_vars.locals.regional_tags,
    local.environment_tags,
    {
      managed_by   = "terraform"
      iac_tool     = "terragrunt"
      project      = local.project_name
      owner        = "platform-team"
      created_by   = "terragrunt-hardened"
    }
  )
}
