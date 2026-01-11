# Environment-wide configuration for PROD
# All submodules in this environment will consume these values
# Change values here once, and all modules will use them

locals {
  environment         = "prod"
  resource_group_name = "terragrunt-hardened-prod-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  
  # Network Configuration
  network_cidr = "172.16.0.0/16"
  
  # Compute Configuration
  vm_size        = "Standard_D2s_v3"
  instance_count = 4
  
  # Storage Configuration
  storage_tier = "Premium"
  
  # Database Configuration
  database_tier = "Premium"
  
  # Security & Compliance (Prod - Enhanced)
  enable_encryption = true
  enable_backup     = true
  enable_monitoring = true
  
  # Enhanced retention for production
  backup_retention_days = 35
  log_retention_days    = 90
  
  # Common Tags for all resources
  common_tags = {
    environment  = "prod"
    managed_by   = "terraform"
    project      = "terragrunt-hardened"
    cost_center  = "production"
    owner        = "platform-team"
    compliance   = "required"
  }
}
