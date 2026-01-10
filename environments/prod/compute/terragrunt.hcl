# Prod Environment - Compute Deployment (Hardened)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/compute"
}

inputs = {
  environment         = "prod"
  resource_group_name = "terragrunt-hardened-prod-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  vm_size             = "Standard_D2s_v3"
  instance_count      = 4
  enable_monitoring   = true
}
