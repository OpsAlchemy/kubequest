# Terragrunt Hardened Infrastructure Project

A production-ready Terragrunt project demonstrating best practices for organizing infrastructure as code with centralized configuration management.

## Project Structure

```
terragrunt-01/
├── root.hcl                           # Root configuration (Azure provider, backend)
├── modules/                            # Reusable Terraform modules
│   ├── app/                           # Basic application module
│   ├── network/                       # VNet, Subnets, NSGs, Route Tables
│   ├── storage/                       # Storage Accounts, Key Vault, Encryption
│   ├── compute/                       # VMs, NICs, Managed Disks, Backups
│   ├── database/                      # SQL Server, TDE, Threat Detection
│   └── monitoring/                    # Log Analytics, Alerts, Azure Policy
├── environments/
│   ├── dev/
│   │   ├── env.hcl                   # ⭐ Centralized dev configuration
│   │   ├── app/
│   │   ├── network/
│   │   ├── storage/
│   │   ├── compute/
│   │   ├── database/
│   │   └── monitoring/
│   ├── staging/
│   │   ├── env.hcl                   # ⭐ Centralized staging configuration
│   │   └── app/
│   └── prod/
│       ├── env.hcl                   # ⭐ Centralized prod configuration
│       ├── app/
│       ├── network/
│       ├── storage/
│       ├── compute/
│       ├── database/
│       └── monitoring/
├── README.md                          # This file
├── README-HARDENED.md                 # Security & architecture guide
├── HARDENING-SUMMARY.md               # Quick security summary
├── QUICKSTART.md                      # Quick start guide
└── terraform.tfvars.example           # Variable template
```

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.0
- [Terragrunt](https://terragrunt.gruntwork.io/docs/getting-started/install/) >= 0.97.0

### Install Terragrunt v0.97.2

```bash
# Download Terragrunt
wget https://github.com/gruntwork-io/terragrunt/releases/download/v0.97.2/terragrunt_linux_amd64
chmod +x terragrunt_linux_amd64
sudo mv terragrunt_linux_amd64 /usr/local/bin/terragrunt

# Verify installation
terragrunt --version
```

## Quick Start

### Deploy Entire Environment at Once

```bash
# Navigate to environment directory
cd environments/dev

# Initialize ALL modules
terragrunt run --all init

# Apply ALL modules (non-interactive)
terragrunt run --all --non-interactive -- apply -auto-approve

# Destroy ALL modules
terragrunt run --all --non-interactive -- destroy -auto-approve
```

### Deploy Individual Module

```bash
cd environments/dev/network
terragrunt init
terragrunt plan
terragrunt apply
```

## Key Features

### ⭐ Centralized Configuration (env.hcl)

Each environment has a single `env.hcl` file that defines ALL configuration for that environment:

```hcl
# environments/dev/env.hcl
locals {
  environment         = "dev"
  resource_group_name = "terragrunt-hardened-dev-rg"
  location            = "East US"
  vm_size             = "Standard_B2s"
  instance_count      = 2
  storage_tier        = "Standard"
  database_tier       = "Standard"
  # ... all other configuration
}
```

**Benefits:**
- **Single Source of Truth**: Change configuration in ONE file
- **DRY Principle**: No repeated values across modules
- **Easy Environment Promotion**: Copy env.hcl and adjust values
- **Consistency**: All modules use the same configuration

### How Submodules Consume env.hcl

Each submodule's `terragrunt.hcl` reads from the parent `env.hcl`:

```hcl
locals {
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

inputs = {
  environment         = local.env_vars.locals.environment
  resource_group_name = local.env_vars.locals.resource_group_name
  # ... automatically inherited from env.hcl
}
```

### DRY Configuration Hierarchy

```
root.hcl                    # Provider configuration, backend
  └── env.hcl               # Environment-specific variables (dev/staging/prod)
       └── terragrunt.hcl   # Module-specific configuration (consumes from env.hcl)
```

### Remote State Management

- Local backend by default (easily changed to S3/Azure Blob)
- Automatic state file organization by environment
- State isolation between environments

## Common Commands (Terragrunt v0.97+)

```bash
# Initialize single module
terragrunt init

# Plan changes
terragrunt plan

# Apply changes
terragrunt apply

# Show outputs
terragrunt output

# Destroy resources
terragrunt destroy

# Run command on ALL modules in environment
terragrunt run --all init
terragrunt run --all plan
terragrunt run --all --non-interactive -- apply -auto-approve
terragrunt run --all --non-interactive -- destroy -auto-approve

# Format HCL files
terragrunt hclfmt

# Validate configuration
terragrunt validate
```

> **Note:** Terragrunt v0.97+ uses `terragrunt run --all` instead of the older `terragrunt run-all` syntax.

## Environment Configuration

### Development (dev)
| Setting | Value |
|---------|-------|
| VM Size | Standard_B2s |
| Instance Count | 2 |
| Storage Tier | Standard |
| Database Tier | Standard |
| Backup Retention | 7 days |
| Log Retention | 30 days |
| Public IPs | Enabled |

### Staging (staging)
| Setting | Value |
|---------|-------|
| VM Size | Standard_B2s |
| Instance Count | 2 |
| Storage Tier | Standard |
| Database Tier | Standard |
| Backup Retention | 14 days |
| Log Retention | 45 days |

### Production (prod)
| Setting | Value |
|---------|-------|
| VM Size | Standard_D2s_v3 |
| Instance Count | 4 |
| Storage Tier | Premium |
| Database Tier | Premium |
| Backup Retention | 35 days |
| Log Retention | 90 days |
| Public IPs | Disabled |
| Geo-Replication | Enabled |

## Customization

### Modify Environment Configuration

Edit the centralized `env.hcl` file:

```bash
# Edit dev configuration
vim environments/dev/env.hcl

# Changes automatically apply to ALL modules in dev
cd environments/dev
terragrunt run --all --non-interactive -- apply -auto-approve
```

### Add a New Environment

1. Copy an existing environment:
   ```bash
   cp -r environments/dev environments/qa
   ```

2. Update `environments/qa/env.hcl` with QA-specific values

3. Deploy:
   ```bash
   cd environments/qa
   terragrunt run --all --non-interactive -- apply -auto-approve
   ```

### Add a New Module

1. Create module in `modules/`:
   ```bash
   mkdir -p modules/newmodule
   # Add main.tf, variables.tf, outputs.tf
   ```

2. Create environment directories:
   ```bash
   mkdir -p environments/dev/newmodule
   mkdir -p environments/prod/newmodule
   ```

3. Create `terragrunt.hcl` that consumes from `env.hcl`:
   ```hcl
   include "root" {
     path = find_in_parent_folders("root.hcl")
   }

   locals {
     env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
   }

   terraform {
     source = "${get_parent_terragrunt_dir()}/modules/newmodule"
   }

   inputs = {
     environment = local.env_vars.locals.environment
     # ... other inputs from env.hcl
   }
   ```

### Change Backend to S3

Update `root.hcl`:

```hcl
remote_state {
  backend = "s3"
  config = {
    bucket         = "my-terraform-state"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
  generate = {
    path      = "backend.tf"
    if_exists = "overwrite_terragrunt"
  }
}
```

## Troubleshooting

### Module Not Found
```bash
terragrunt init
```

### State Lock Issues
```bash
rm -rf .terragrunt-cache/
terragrunt init
```

### Provider Issues
```bash
terragrunt providers lock
terragrunt validate
```

### View Debug Output
```bash
TG_LOG=debug terragrunt plan
```

## Learn More

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)
- [README-HARDENED.md](./README-HARDENED.md) - Detailed security guide
- [QUICKSTART.md](./QUICKSTART.md) - Quick start instructions

---

**Version:** 2.0 - Centralized Configuration with env.hcl  
**Terragrunt:** v0.97.2  
**Last Updated:** January 2026
