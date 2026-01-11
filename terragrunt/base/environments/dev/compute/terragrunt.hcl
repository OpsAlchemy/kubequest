# Dev Environment - Compute Deployment
# Consumes shared configuration from env.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Load environment-wide variables
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/compute"
}

# All inputs come from env.hcl - DRY!
inputs = {
  environment         = local.env_vars.locals.environment
  resource_group_name = local.env_vars.locals.resource_group_name
  location            = local.env_vars.locals.location
  project_name        = local.env_vars.locals.project_name
  vm_size             = local.env_vars.locals.vm_size
  instance_count      = local.env_vars.locals.instance_count
  enable_monitoring   = local.env_vars.locals.enable_monitoring
  common_tags         = local.env_vars.locals.common_tags
}
