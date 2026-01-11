# Terraform Workspace (base is the main project)

This folder contains Terraform helper files and a self-contained Terraform project inside the `base/` directory.

The `base/` directory is the authoritative Terraform project — it contains provider configuration, variables, and example resources. There are intentionally no Terraform files in the repository root so you can treat `base/` as a standalone workspace.

## Quick start (use `base/`)

```bash
cd terraform/base
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

## Project Layout

```
terraform/
├── .gitignore           # Root-level gitignore (non-Terraform files)
├── README.md            # This file
└── base/                # Self-contained Terraform project
    ├── .gitignore
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    ├── terraform.tfvars
    └── README.md
```

## Where to run

- Run `terraform` commands from `terraform/base` (or pass `-chdir=base`):

```bash
# from repo root
terraform -chdir=terraform/base init
terraform -chdir=terraform/base plan -var-file=terraform/base/terraform.tfvars
```

## Tips

- Keep secrets out of source control. Add any secret `.tfvars` files to `.gitignore`.
- Use a remote backend for team environments (bucket + locking table) — configure it inside `base/main.tf` and then run `terraform init` to migrate state.
- Use `terraform fmt -recursive` and `terraform validate` before planning.

## Documentation

See `terraform/base/README.md` for details about variables, example resources, and recommended workflows.

If you want a small wrapper script to run commands against the `base/` project, tell me and I'll add `terraform/run.sh`.
