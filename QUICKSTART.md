# Quick Start Guide

## Test the Project

1. **Navigate to dev environment:**
   ```bash
   cd /home/vagabond/dev/terragrunt-01/environments/dev/app
   ```

2. **Initialize:**
   ```bash
   terragrunt init
   ```

3. **Plan:**
   ```bash
   terragrunt plan
   ```

4. **Apply:**
   ```bash
   terragrunt apply
   ```

5. **View outputs:**
   ```bash
   terragrunt output
   ```

6. **Clean up:**
   ```bash
   terragrunt destroy
   ```

## What's Included

- ✅ Root terragrunt.hcl with common configuration
- ✅ Reusable app module (using null provider for demonstration)
- ✅ Three environments: dev, staging, prod
- ✅ Local backend configuration (ready for S3/remote backend)
- ✅ Auto-generated provider configuration
- ✅ Proper .gitignore for Terraform/Terragrunt
- ✅ Comprehensive documentation

## Expected Output

When you run `terragrunt apply` in the dev environment, you'll see:
- 2 null resources created (instance_count = 2)
- Output showing app_info and deployment_message
- State file created in terraform.tfstate.d/environments/dev/app/

Each environment has different instance counts:
- Dev: 2 instances
- Staging: 2 instances  
- Prod: 3 instances
