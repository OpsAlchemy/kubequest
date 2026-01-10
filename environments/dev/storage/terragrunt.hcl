# Dev Environment - Storage Deployment
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/storage"
}

inputs = {
  environment         = "dev"
  resource_group_name = "terragrunt-hardened-dev-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  storage_tier        = "Standard"
  enable_encryption   = true
  enable_backup       = true
}
