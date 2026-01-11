# Include root terragrunt configuration
include "root" {
  path = find_in_parent_folders("root.hcl")
}

# Reference the app module
terraform {
  source = "${get_parent_terragrunt_dir()}/modules/app"
}

# Environment-specific inputs
inputs = {
  environment    = "dev"
  app_name       = "web-app"
  instance_count = 2
}
