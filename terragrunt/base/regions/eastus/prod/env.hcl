# =============================================================================
# ENVIRONMENT CONFIGURATION - PROD (US East Region)
# =============================================================================
# Production environment with full security, DR, and compliance
# =============================================================================

locals {
  # ==========================================================================
  # INHERIT FROM REGION
  # ==========================================================================
  region_vars = read_terragrunt_config(find_in_parent_folders("region.hcl"))
  
  azure_region         = local.region_vars.locals.azure_region
  azure_region_display = local.region_vars.locals.azure_region_display
  region_code          = local.region_vars.locals.region_code
  dr_azure_region      = local.region_vars.locals.dr_azure_region
  
  compliance_frameworks = local.region_vars.locals.compliance_frameworks
  data_residency        = local.region_vars.locals.data_residency
  
  environment_address_spaces = local.region_vars.locals.environment_address_spaces
  service_endpoints          = local.region_vars.locals.service_endpoints
  private_dns_zones          = local.region_vars.locals.private_dns_zones
  
  availability_zones = local.region_vars.locals.availability_zones
  encryption_settings = local.region_vars.locals.encryption_settings
  log_analytics_workspace = local.region_vars.locals.log_analytics_workspace
  resource_abbreviations = local.region_vars.locals.resource_abbreviations
  
  # ==========================================================================
  # ENVIRONMENT IDENTIFICATION
  # ==========================================================================
  environment       = "prod"
  environment_code  = "p"
  environment_name  = "Production"
  is_production     = true
  
  # ==========================================================================
  # AZURE RESOURCE NAMING
  # ==========================================================================
  naming_prefix       = "cmp-${local.region_code}-${local.environment_code}"
  resource_group_name = "${local.naming_prefix}-rg"
  project_name        = "terragrunt-hardened"
  
  # ==========================================================================
  # AZURE NETWORKING - ENVIRONMENT SPECIFIC
  # ==========================================================================
  network_cidr = local.environment_address_spaces[local.environment]  # 10.2.0.0/16
  
  subnet_cidrs = {
    web     = cidrsubnet(local.network_cidr, 8, 0)
    app     = cidrsubnet(local.network_cidr, 7, 1)
    data    = cidrsubnet(local.network_cidr, 8, 4)
    bastion = cidrsubnet(local.network_cidr, 10, 20)
    gateway = cidrsubnet(local.network_cidr, 10, 21)
    private_endpoints = cidrsubnet(local.network_cidr, 8, 10)
  }
  
  dns_zone_name = "${local.environment}.${local.region_code}.internal.company.com"
  
  # ==========================================================================
  # AZURE COMPUTE - PRODUCTION SIZED
  # ==========================================================================
  vm_sizes = {
    web  = "Standard_D4s_v3"
    app  = "Standard_D8s_v3"
    data = "Standard_E4s_v3"
  }
  
  instance_counts = {
    web  = 4
    app  = 6
    data = 2
  }
  
  enable_public_ips = false  # NO public IPs in prod
  
  # ==========================================================================
  # AZURE STORAGE - PRODUCTION GRADE
  # ==========================================================================
  storage_tier             = "Premium"
  storage_replication_type = "GRS"  # Geo-redundant for prod
  
  # ==========================================================================
  # AZURE DATABASE - PRODUCTION GRADE
  # ==========================================================================
  database_tier = "P2"  # Premium tier for prod
  database_sku  = "Premium"
  database_dtus = 250
  
  backup_retention_days      = 35
  geo_redundant_backup       = true
  point_in_time_restore_days = 35
  
  # Long-term retention
  ltr_weekly_retention  = "P4W"
  ltr_monthly_retention = "P12M"
  ltr_yearly_retention  = "P5Y"
  
  # ==========================================================================
  # AZURE MONITORING - FULL PRODUCTION
  # ==========================================================================
  log_retention_days    = 90
  enable_advanced_monitoring = true
  enable_threat_detection = true
  
  alert_severity_threshold = 4  # All alerts
  enable_pager_alerts      = true
  
  # ==========================================================================
  # AZURE SECURITY - FULL PRODUCTION
  # ==========================================================================
  enable_encryption    = true
  enable_cmk           = true  # Customer-managed keys
  enable_backup        = true
  enable_monitoring    = true
  enable_waf           = true  # WAF enabled
  enable_ddos_protection = true  # DDoS enabled
  
  allow_public_access    = false  # NO public access in prod
  enable_private_endpoints = true  # All private endpoints
  
  # ==========================================================================
  # AZURE DISASTER RECOVERY - FULL PRODUCTION
  # ==========================================================================
  enable_dr             = true
  enable_geo_replication = true
  dr_target_region      = local.dr_azure_region
  
  # ==========================================================================
  # AZURE COST MANAGEMENT
  # ==========================================================================
  cost_center = "PROD-${upper(local.region_code)}-001"
  budget_amount = 50000
  
  auto_shutdown_enabled = false  # Never auto-shutdown prod
  auto_shutdown_time    = null
  auto_shutdown_timezone = null
  
  # ==========================================================================
  # ENVIRONMENT TAGS
  # ==========================================================================
  environment_tags = {
    environment      = local.environment
    environment_name = local.environment_name
    is_production    = tostring(local.is_production)
    cost_center      = local.cost_center
    dr_enabled       = tostring(local.enable_dr)
    compliance       = join(",", local.compliance_frameworks)
    sla_tier         = "platinum"
  }
  
  common_tags = merge(
    local.region_vars.locals.regional_tags,
    local.environment_tags,
    {
      managed_by   = "terraform"
      iac_tool     = "terragrunt"
      project      = local.project_name
      owner        = "platform-team"
      created_by   = "terragrunt-hardened"
      criticality  = "high"
      change_window = "weekends-only"
    }
  )
}
