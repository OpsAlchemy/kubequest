# Hardened Terragrunt Infrastructure - Security & Architecture Guide

## Overview

This project demonstrates a hardened, production-ready Terragrunt infrastructure emulating Azure resources with security best practices and **centralized configuration management** using `env.hcl`.

## Architecture

```
terragrunt-hardened/
├── root.hcl                           # Root configuration with Azure provider
├── modules/                            # Reusable hardened modules
│   ├── network/                       # VNet, Subnets, NSGs, Route Tables
│   ├── storage/                       # Storage Accounts, Containers, Key Vault
│   ├── compute/                       # VMs, NICs, Managed Disks, Backups
│   ├── database/                      # SQL Server, Databases, TDE, Firewall
│   └── monitoring/                    # Log Analytics, App Insights, Alerts
├── environments/
│   ├── dev/
│   │   ├── env.hcl                   # ⭐ CENTRALIZED DEV CONFIG
│   │   ├── network/terragrunt.hcl
│   │   ├── storage/terragrunt.hcl
│   │   ├── compute/terragrunt.hcl
│   │   ├── database/terragrunt.hcl
│   │   └── monitoring/terragrunt.hcl
│   ├── staging/
│   │   └── env.hcl                   # ⭐ CENTRALIZED STAGING CONFIG
│   └── prod/
│       ├── env.hcl                   # ⭐ CENTRALIZED PROD CONFIG
│       ├── network/terragrunt.hcl
│       ├── storage/terragrunt.hcl
│       ├── compute/terragrunt.hcl
│       ├── database/terragrunt.hcl
│       └── monitoring/terragrunt.hcl
└── README-HARDENED.md
```

## ⭐ Centralized Configuration Pattern

### The env.hcl File

Each environment has ONE configuration file that ALL modules consume:

```hcl
# environments/dev/env.hcl
locals {
  environment         = "dev"
  resource_group_name = "terragrunt-hardened-dev-rg"
  location            = "East US"
  project_name        = "tg-hardened"
  
  # Network Configuration
  network_cidr = "10.0.0.0/16"
  
  # Compute Configuration
  vm_size        = "Standard_B2s"
  instance_count = 2
  
  # Storage Configuration
  storage_tier = "Standard"
  
  # Database Configuration
  database_tier = "Standard"
  
  # Security & Compliance
  enable_encryption = true
  enable_backup     = true
  enable_monitoring = true
  
  # Retention Policies
  backup_retention_days = 7
  log_retention_days    = 30
  
  # Common Tags for all resources
  common_tags = {
    environment  = "dev"
    managed_by   = "terraform"
    project      = "terragrunt-hardened"
    cost_center  = "engineering"
    owner        = "platform-team"
  }
}
```

### How Modules Consume Configuration

Every submodule's `terragrunt.hcl` uses `read_terragrunt_config()`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

locals {
  # Read centralized configuration from parent env.hcl
  env_vars = read_terragrunt_config(find_in_parent_folders("env.hcl"))
}

terraform {
  source = "${get_parent_terragrunt_dir()}/modules/network"
}

inputs = {
  # All values come from env.hcl - single source of truth
  environment         = local.env_vars.locals.environment
  resource_group_name = local.env_vars.locals.resource_group_name
  location            = local.env_vars.locals.location
  project_name        = local.env_vars.locals.project_name
  network_cidr        = local.env_vars.locals.network_cidr
  common_tags         = local.env_vars.locals.common_tags
}
```

### Benefits of Centralized Configuration

| Benefit | Description |
|---------|-------------|
| **Single Source of Truth** | All configuration in ONE file per environment |
| **DRY Principle** | No repeated values across modules |
| **Easy Changes** | Modify env.hcl → all modules updated |
| **Environment Promotion** | Copy env.hcl, adjust values, deploy |
| **Consistency** | Guaranteed same config across all modules |
| **Auditing** | Easy to review environment differences |

## Security Features by Module

### 1. Network Module
✅ Virtual Network (VNET) with custom CIDR blocks  
✅ Multiple subnets with service endpoints  
✅ Network Security Groups (NSG) with firewall rules  
✅ DDoS Protection enabled  
✅ Route Tables for traffic management  
✅ Threat protection on network rules  

**Resources Created:**
- 1 Virtual Network
- 3 Subnets (web, app, data)
- 3 Network Security Groups
- 1 Route Table

### 2. Storage Module
✅ Azure Storage Accounts with AES-256 encryption  
✅ HTTPS-only traffic enforcement  
✅ TLS 1.2 minimum requirement  
✅ Private blob containers  
✅ Immutable storage enabled  
✅ Azure Key Vault for secret management  
✅ Soft delete and versioning  
✅ Network isolation (Default: Deny)  

**Resources Created:**
- 1 Storage Account
- 3 Blob Containers
- 1 Key Vault with purge protection
- 2 Stored Secrets

### 3. Compute Module
✅ Azure Virtual Machines with OS disk encryption  
✅ Managed Disks with encryption  
✅ System-Managed Identity enabled  
✅ Boot diagnostics enabled  
✅ Automatic patching (AutomaticByPlatform)  
✅ Hot patching for critical updates  
✅ Azure Backup integration  
✅ Environment-specific public IP (dev only)  

### 4. Database Module
✅ Azure SQL Server with managed identity  
✅ Transparent Data Encryption (TDE)  
✅ Threat Detection & Vulnerability Assessment  
✅ Automatic backup with custom retention  
✅ Geo-replication (prod only)  
✅ Firewall rules with network isolation  
✅ Audit logging  
✅ Key rotation every 90 days  

### 5. Monitoring Module
✅ Log Analytics Workspace with CMK encryption (prod)  
✅ Application Insights for APM  
✅ Diagnostic Settings for resource logging  
✅ Metric Alerts (CPU, Memory, Disk, Network)  
✅ Log Search Alerts for suspicious activities  
✅ Action Groups with email & webhook  
✅ Azure Policy enforcement with auto-remediation  

## Deploying Infrastructure

### Full Environment Deployment (Recommended)

```bash
# Navigate to environment
cd /home/vagabond/dev/terragrunt-01/environments/dev

# Initialize ALL modules
terragrunt run --all init

# Apply ALL modules
terragrunt run --all --non-interactive -- apply -auto-approve

# Destroy ALL modules
terragrunt run --all --non-interactive -- destroy -auto-approve
```

### Individual Module Deployment

```bash
cd environments/dev/network
terragrunt init
terragrunt plan
terragrunt apply
```

### View All Outputs

```bash
cd environments/dev
terragrunt run --all output
```

## Environment-Specific Configurations

### Development (dev/env.hcl)
| Setting | Value |
|---------|-------|
| VNET CIDR | 10.0.0.0/16 |
| VM Size | Standard_B2s |
| Instance Count | 2 |
| Storage Tier | Standard |
| Database Tier | Standard |
| Public IPs | Enabled |
| Backup Retention | 7 days |
| Log Retention | 30 days |

### Production (prod/env.hcl)
| Setting | Value |
|---------|-------|
| VNET CIDR | 172.16.0.0/16 |
| VM Size | Standard_D2s_v3 |
| Instance Count | 4 |
| Storage Tier | Premium |
| Database Tier | Premium |
| Public IPs | Disabled |
| Backup Retention | 35 days |
| Log Retention | 90 days |
| Geo-Replication | Enabled |
| CMK Encryption | Enabled |

## Security Best Practices Implemented

### 1. Data Encryption
- ✅ AES-256 encryption at rest
- ✅ TLS 1.2+ for data in transit
- ✅ Transparent Database Encryption (TDE)
- ✅ Customer-Managed Keys (CMK) in prod
- ✅ OS disk encryption on all VMs

### 2. Access Control
- ✅ RBAC (Role-Based Access Control)
- ✅ Managed Identities for service authentication
- ✅ Network isolation (private endpoints)
- ✅ Firewall rules with least privilege
- ✅ Azure Key Vault for secrets

### 3. Monitoring & Alerting
- ✅ Comprehensive logging (30-90 days retention)
- ✅ Real-time metric alerts
- ✅ Security event monitoring
- ✅ Threat detection enabled
- ✅ Vulnerability scanning enabled

### 4. Backup & Disaster Recovery
- ✅ Automated VM backups
- ✅ Database point-in-time restore
- ✅ Geo-replication (prod)
- ✅ Long-term retention (prod)

### 5. Compliance & Governance
- ✅ Azure Policies enforced
- ✅ Auto-remediation for non-compliant resources
- ✅ Audit logging enabled
- ✅ Consistent tagging strategy

## Security Checklist

Before deploying to production:

- [ ] Update `env.hcl` with production values
- [ ] Set up Azure Key Vault with proper RBAC
- [ ] Configure remote state backend with encryption
- [ ] Enable Azure Policy for compliance
- [ ] Set up Azure AD groups for RBAC
- [ ] Configure backup retention per compliance
- [ ] Set up monitoring dashboards and alert actions
- [ ] Review and approve all NSG rules
- [ ] Enable Azure Defender for threat protection
- [ ] Test disaster recovery procedures

## Variables Management

### Sensitive Variables (NEVER commit to git)
```bash
export AZURE_SUBSCRIPTION_ID="your-sub-id"
export AZURE_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-sp-client-id"
export ARM_CLIENT_SECRET="your-sp-client-secret"
```

### Modify Environment Variables
```bash
# Edit the centralized configuration
vim environments/prod/env.hcl

# Apply changes to all modules
cd environments/prod
terragrunt run --all --non-interactive -- apply -auto-approve
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

### Debug Mode
```bash
TG_LOG=debug terragrunt plan
```

## Learning Resources

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
- [Infrastructure as Code Best Practices](https://www.terraform.io/cloud-docs/recommended-practices/)

---

**Version:** 2.0 - Centralized Configuration with env.hcl  
**Terragrunt:** v0.97.2  
**Status:** Production Ready  
**Last Updated:** January 2026
