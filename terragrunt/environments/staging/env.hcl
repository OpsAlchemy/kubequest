# Environment-wide configuration for STAGING
# All submodules in this environment will consume these values
# Change values here once, and all modules will use them

locals {
  environment         = "staging"
  resource_group_name = "terragrunt-hardened-staging-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  
  # Network Configuration
  network_cidr = "192.168.0.0/16"
  
  # Compute Configuration
  vm_size        = "Standard_B2s"
  instance_count = 2
  
  # Storage Configuration
  storage_tier = "Standard"
  
  # Database Configuration
  database_tier = "Standard"
  
  # Security & Compliance (Staging - same as prod for testing)
  enable_encryption = true
  enable_backup     = true
  enable_monitoring = true
  
  # Moderate retention for staging
  backup_retention_days = 14
  log_retention_days    = 30
  
  # Common Tags for all resources
  common_tags = {
    environment  = "staging"
    managed_by   = "terraform"
    project      = "terragrunt-hardened"
    cost_center  = "engineering"
    owner        = "platform-team"
  }
}
