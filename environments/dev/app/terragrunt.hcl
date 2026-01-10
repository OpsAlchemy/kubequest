# Include root terragrunt configuration
include "root" {
  path = find_in_parent_folders()
}

# Reference the app module
terraform {
  source = "../../modules/app"
}

# Environment-specific inputs
inputs = {
  environment    = "dev"
  app_name       = "web-app"
  instance_count = 2
}
