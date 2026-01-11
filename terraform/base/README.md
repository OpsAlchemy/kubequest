# Terraform Base Project

This `base/` directory is a self-contained Terraform project (standalone).

Use this directory to develop and apply infrastructure resources locally or to use as a starting module for other projects.

Quick start:

```bash
cd terraform/base
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Files:
- `main.tf` - provider and resource definitions
- `variables.tf` - input variables for the project
- `outputs.tf` - outputs
- `terraform.tfvars` - local variable values (ignored at repo root by .gitignore)

Notes:
- This project is intentionally self-contained. Do not expect to run from the repository root.
- Keep secrets out of git and put them in secure storage.
