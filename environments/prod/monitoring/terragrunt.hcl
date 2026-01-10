# Prod Environment - Monitoring Deployment (Enhanced)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/monitoring"
}

inputs = {
  environment         = "prod"
  resource_group_name = "terragrunt-hardened-prod-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  enable_monitoring   = true
}
