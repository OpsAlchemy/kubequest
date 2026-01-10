# Prod Environment - Storage Deployment (Hardened)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/storage"
}

inputs = {
  environment         = "prod"
  resource_group_name = "terragrunt-hardened-prod-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  storage_tier        = "Premium"
  enable_encryption   = true
  enable_backup       = true
}
