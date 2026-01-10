# Prod Environment - Network Deployment (Hardened)
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/network"
}

inputs = {
  environment         = "prod"
  resource_group_name = "terragrunt-hardened-prod-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  network_cidr        = "172.16.0.0/16"
  enable_encryption   = true
}
