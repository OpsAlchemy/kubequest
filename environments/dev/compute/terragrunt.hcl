# Dev Environment - Compute Deployment
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/compute"
}

inputs = {
  environment         = "dev"
  resource_group_name = "terragrunt-hardened-dev-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  vm_size             = "Standard_B2s"
  instance_count      = 2
  enable_monitoring   = true
}
