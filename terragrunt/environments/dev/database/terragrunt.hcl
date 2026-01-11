# Dev Environment - Database Deployment
# Consumes shared configuration from env.hcl

include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Load environment-wide variables
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/database"
}

# All inputs come from env.hcl - DRY!
inputs = {
  environment         = local.env_vars.locals.environment
  resource_group_name = local.env_vars.locals.resource_group_name
  location            = local.env_vars.locals.location
  project_name        = local.env_vars.locals.project_name
  database_tier       = local.env_vars.locals.database_tier
  enable_encryption   = local.env_vars.locals.enable_encryption
  enable_backup       = local.env_vars.locals.enable_backup
  common_tags         = local.env_vars.locals.common_tags
}
