# Quick Start Guide

## Prerequisites

- Terraform >= 1.0
- Terragrunt >= 0.97.0

## 1. Deploy Entire Environment (Recommended)

```bash
# Navigate to dev environment
cd /home/vagabond/dev/terragrunt-01/environments/dev

# Initialize ALL modules
terragrunt run --all init

# Apply ALL modules (non-interactive)
terragrunt run --all --non-interactive -- apply -auto-approve

# View all outputs
terragrunt run --all output
```

## 2. Deploy Individual Module

```bash
cd /home/vagabond/dev/terragrunt-01/environments/dev/network

terragrunt init
terragrunt plan
terragrunt apply
```

## 3. Modify Configuration

Edit the centralized `env.hcl` file - changes apply to ALL modules:

```bash
# Edit configuration
vim environments/dev/env.hcl

# Apply changes
cd environments/dev
terragrunt run --all --non-interactive -- apply -auto-approve
```

## 4. Clean Up

```bash
cd /home/vagabond/dev/terragrunt-01/environments/dev
terragrunt run --all --non-interactive -- destroy -auto-approve
```

## What's Included

### Modules
- ✅ **network** - VNet, subnets, NSGs, route tables
- ✅ **storage** - Storage accounts, Key Vault, encryption
- ✅ **compute** - VMs, NICs, managed disks, backups
- ✅ **database** - SQL Server, TDE, threat detection
- ✅ **monitoring** - Log Analytics, alerts, Azure Policy
- ✅ **app** - Basic application module

### Configuration
- ✅ Centralized `env.hcl` per environment (dev, staging, prod)
- ✅ Root `root.hcl` with provider configuration
- ✅ Local backend (ready for S3/Azure Blob)
- ✅ Auto-generated provider configuration

### Environments
| Environment | Modules | Config File |
|-------------|---------|-------------|
| dev | All 6 | `environments/dev/env.hcl` |
| staging | app | `environments/staging/env.hcl` |
| prod | All 6 | `environments/prod/env.hcl` |

## Key Commands (Terragrunt v0.97+)

```bash
# Run on ALL modules in environment
terragrunt run --all init
terragrunt run --all plan
terragrunt run --all --non-interactive -- apply -auto-approve
terragrunt run --all --non-interactive -- destroy -auto-approve
terragrunt run --all output

# Run on SINGLE module
terragrunt init
terragrunt plan
terragrunt apply
terragrunt output
terragrunt destroy
```

> **Note:** Terragrunt v0.97+ uses `terragrunt run --all` instead of `terragrunt run-all`

## Expected Output

When you run `terragrunt run --all apply` in the dev environment:

```
Run Summary
6 units 2m30s
========
Succeeded 6
```

Each module produces outputs showing:
- Network: VNet ID, subnet IDs, NSG rules
- Storage: Storage account ID, Key Vault name
- Compute: VM IDs, NIC details, backup status
- Database: SQL Server info, encryption status
- Monitoring: Log Analytics workspace, alerts configured

## Configuration Structure

```
root.hcl              → Provider setup, backend config
  │
  └── env.hcl         → ⭐ ALL environment variables (edit THIS file)
        │
        ├── network/terragrunt.hcl   → Consumes from env.hcl
        ├── storage/terragrunt.hcl   → Consumes from env.hcl
        ├── compute/terragrunt.hcl   → Consumes from env.hcl
        ├── database/terragrunt.hcl  → Consumes from env.hcl
        └── monitoring/terragrunt.hcl → Consumes from env.hcl
```

## Troubleshooting

```bash
# Module not found
terragrunt init

# Clear cache
rm -rf .terragrunt-cache/

# Debug mode
TG_LOG=debug terragrunt plan
```

---

**Version:** 2.0  
**Terragrunt:** v0.97.2  
**Last Updated:** January 2026
