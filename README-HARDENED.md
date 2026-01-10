# Hardened Terragrunt Infrastructure - Security & Architecture Guide

## Overview

This project demonstrates a hardened, production-ready Terragrunt infrastructure emulating Azure resources with security best practices.

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
│   │   ├── network/
│   │   ├── storage/
│   │   ├── compute/
│   │   ├── database/
│   │   └── monitoring/
│   └── prod/
│       ├── network/
│       ├── storage/
│       ├── compute/
│       ├── database/
│       └── monitoring/
└── README-HARDENED.md
```

## Security Features by Module

### 1. Network Module
✅ Virtual Network (VNET) with custom CIDR blocks
✅ Multiple subnets with service endpoints
✅ Network Security Groups (NSG) with firewall rules
✅ DDoS Protection enabled
✅ Route Tables for traffic management
✅ Threat protection on network rules

**Example Usage:**
```bash
cd environments/dev/network
terragrunt init
terragrunt plan
terragrunt apply
```

### 2. Storage Module
✅ Azure Storage Accounts with encryption
✅ HTTPS-only traffic enforcement
✅ TLS 1.2 minimum requirement
✅ Private blob containers
✅ Immutable storage enabled
✅ Azure Key Vault for secret management
✅ Soft delete and versioning
✅ Point-in-time restore capability
✅ Network isolation (Default: Deny)

**Example Usage:**
```bash
cd environments/dev/storage
terragrunt plan
terragrunt apply
```

### 3. Compute Module
✅ Azure Virtual Machines with OS disk encryption
✅ Managed Disks with encryption
✅ System-Managed Identity enabled
✅ Boot diagnostics enabled
✅ Automatic patching (AutomaticByPlatform)
✅ Hot patching for critical updates
✅ Azure Backup integration
✅ Network interfaces with security
✅ Environment-specific public IP (dev only)

**Sizing by Environment:**
- **Dev:** Standard_B2s, 2 instances, public IPs enabled
- **Prod:** Standard_D2s_v3, 4 instances, no public IPs

### 4. Database Module
✅ Azure SQL Server with managed identity
✅ Transparent Data Encryption (TDE)
✅ Threat Detection & Vulnerability Assessment
✅ Automatic backup with custom retention
✅ Geo-replication (prod only)
✅ Firewall rules with network isolation
✅ Advanced Data Security
✅ Audit logging
✅ Encryption algorithm: AES-256
✅ Key rotation every 90 days

**Retention Policies:**
- **Dev:** 7 days
- **Prod:** 35 days + long-term retention (12 weeks)

### 5. Monitoring Module
✅ Log Analytics Workspace with CMK encryption (prod)
✅ Application Insights for APM
✅ Diagnostic Settings for resource logging
✅ Metric Alerts (CPU, Memory, Disk, Network)
✅ Log Search Alerts for suspicious activities
✅ Action Groups with email & webhook
✅ Azure Policy enforcement with auto-remediation
✅ Intelligent threat detection
✅ Security compliance monitoring

**Alerts Included:**
- High CPU usage (>80%)
- Low available memory
- High disk activity
- Unusual network traffic
- Suspicious process execution
- Unauthorized delete operations

## Security Best Practices Implemented

### 1. Data Encryption
- ✅ AES-256 encryption at rest
- ✅ TLS 1.2+ for data in transit
- ✅ Transparent Database Encryption (TDE)
- ✅ Customer-Managed Keys (CMK) in prod
- ✅ OS disk encryption on all VMs
- ✅ Managed disk encryption

### 2. Access Control
- ✅ RBAC (Role-Based Access Control)
- ✅ Managed Identities for service authentication
- ✅ Network isolation (private endpoints)
- ✅ Firewall rules with least privilege
- ✅ Azure Key Vault for secrets
- ✅ NSG rules for network segmentation

### 3. Monitoring & Alerting
- ✅ Comprehensive logging (30-90 days retention)
- ✅ Real-time metric alerts
- ✅ Security event monitoring
- ✅ Threat detection enabled
- ✅ Vulnerability scanning enabled
- ✅ Action groups for incident response

### 4. Backup & Disaster Recovery
- ✅ Automated VM backups
- ✅ Database point-in-time restore (dev)
- ✅ Geo-replication (prod)
- ✅ Long-term retention (prod)
- ✅ Immutable backup copies

### 5. Compliance & Governance
- ✅ Azure Policies enforced
- ✅ Auto-remediation for non-compliant resources
- ✅ Audit logging enabled
- ✅ Consistent tagging strategy
- ✅ Resource isolation by environment

## Environment-Specific Configurations

### Development Environment
- **Tier:** Standard (lower cost)
- **Instances:** 2 VMs
- **Public IPs:** Enabled (for testing)
- **Backup Retention:** 7 days
- **Monitoring:** Essential metrics
- **Use Case:** Testing, development, experimentation

### Production Environment
- **Tier:** Premium (better performance)
- **Instances:** 4 VMs
- **Public IPs:** Disabled (security)
- **Backup Retention:** 35 days + 12-week long-term
- **Geo-Replication:** Enabled (HA/DR)
- **Monitoring:** Full observability with 90-day retention
- **Threat Detection:** Enabled
- **Compliance:** Strict enforcement

## Deploying the Infrastructure

### 1. Initialize All Modules in Dev
```bash
cd /home/vagabond/dev/terragrunt-01

# Run from environment directory
cd environments/dev/network && terragrunt init
cd ../storage && terragrunt init
cd ../compute && terragrunt init
cd ../database && terragrunt init
cd ../monitoring && terragrunt init
```

### 2. Plan All Changes
```bash
# From dev environment
terragrunt run-all plan
```

### 3. Apply Infrastructure
```bash
# Deploy one module at a time
cd environments/dev/network && terragrunt apply
cd ../storage && terragrunt apply
cd ../compute && terragrunt apply
cd ../database && terragrunt apply
cd ../monitoring && terragrunt apply
```

### 4. Full Environment Deployment (All at Once)
```bash
cd /home/vagabond/dev/terragrunt-01
terragrunt run-all apply
```

### 5. Destroy Infrastructure
```bash
# Destroy in reverse order of dependencies
cd environments/dev
terragrunt run-all destroy
```

## Security Checklist

Before deploying to production:

- [ ] Update `terraform.tfvars` with production values
- [ ] Set up Azure Key Vault with proper RBAC
- [ ] Configure storage account for remote state with encryption
- [ ] Enable Azure Policy for compliance
- [ ] Set up Azure AD groups for RBAC
- [ ] Configure backup retention per compliance requirements
- [ ] Set up monitoring dashboards and alert actions
- [ ] Review and approve all NSG rules
- [ ] Enable Azure Defender for threat protection
- [ ] Implement WAF for public-facing resources
- [ ] Set up Azure Sentinel for SIEM
- [ ] Document all access credentials (use Key Vault)
- [ ] Enable audit logging and compliance reports
- [ ] Test disaster recovery procedures

## Variables Management

### Sensitive Variables (NEVER commit to git)
```bash
export AZURE_SUBSCRIPTION_ID="your-sub-id"
export AZURE_TENANT_ID="your-tenant-id"
export ARM_CLIENT_ID="your-sp-client-id"
export ARM_CLIENT_SECRET="your-sp-client-secret"
```

### Use terraform.tfvars.example
```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your values
# Add terraform.tfvars to .gitignore
```

## Troubleshooting

### Module Not Found
```bash
terragrunt init
```

### State Lock Issues
```bash
# Check for locks
ls terraform.tfstate.d/*/
# Remove lock if stuck
rm -rf .terragrunt-cache/
terragrunt init
```

### Provider Issues
```bash
# Update providers
terragrunt providers lock

# Validate configuration
terragrunt validate
```

## Performance Optimization

1. **Parallel Execution:** Use `terragrunt run-all` for concurrent deployments
2. **Caching:** Terragrunt caches modules in `.terragrunt-cache`
3. **State Locking:** Prevents concurrent modifications
4. **Minimal State:** Keep only necessary data in state

## Cost Optimization (Dev Only)

- Use Standard tier instead of Premium
- Enable auto-shutdown for dev VMs
- Use smaller VM sizes (B-series)
- Reduce backup retention
- Disable geo-replication

## Learning Resources

- [Terragrunt Documentation](https://terragrunt.gruntwork.io/)
- [Azure Security Best Practices](https://docs.microsoft.com/azure/security/)
- [Azure Well-Architected Framework](https://docs.microsoft.com/azure/architecture/framework/)
- [Infrastructure as Code Best Practices](https://www.terraform.io/cloud-docs/recommended-practices/)

## Support & Contribution

For issues or improvements:
1. Check existing documentation
2. Review module examples
3. Test changes in dev environment
4. Use descriptive commit messages
5. Update documentation accordingly

---

**Created:** January 2026
**Version:** 1.0 - Hardened Multi-Tier Infrastructure
**Status:** Production Ready
