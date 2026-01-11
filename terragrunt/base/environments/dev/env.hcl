# Environment-wide configuration for DEV
# All submodules in this environment will consume these values
# Change values here once, and all modules will use them

locals {
  environment         = "dev"
  resource_group_name = "terragrunt-hardened-dev-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  
  # Network Configuration
  network_cidr = "10.0.0.0/16"
  
  # Compute Configuration
  vm_size        = "Standard_B2s"
  instance_count = 2
  
  # Storage Configuration
  storage_tier = "Standard"
  
  # Database Configuration
  database_tier = "Standard"
  
  # Security & Compliance (Dev defaults)
  enable_encryption = true
  enable_backup     = true
  enable_monitoring = true
  
  # Cost optimization for dev
  backup_retention_days = 7
  log_retention_days    = 30
  
  # Common Tags for all resources
  common_tags = {
    environment  = "dev"
    managed_by   = "terraform"
    project      = "terragrunt-hardened"
    cost_center  = "engineering"
    owner        = "platform-team"
  }
}
