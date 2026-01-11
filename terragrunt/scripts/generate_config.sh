#!/bin/bash
# =============================================================================
# DYNAMIC CONFIGURATION GENERATOR
# =============================================================================
# This script is called by Terragrunt run_cmd() to generate dynamic
# configuration values at runtime.
#
# Usage: ./generate_config.sh <config_type> <environment> <region>
#
# Config Types:
#   - naming      : Generate resource names
#   - secrets     : Fetch secrets from Azure Key Vault
#   - ip_ranges   : Calculate IP ranges dynamically
#   - timestamps  : Generate timestamps for tags
#   - compliance  : Check compliance requirements
# =============================================================================

set -euo pipefail

CONFIG_TYPE="${1:-naming}"
ENVIRONMENT="${2:-dev}"
REGION="${3:-eastus}"

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_info() {
    echo -e "${GREEN}[INFO]${NC} $1" >&2
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

# =============================================================================
# NAMING GENERATOR
# =============================================================================
generate_naming() {
    local env_code
    case "$ENVIRONMENT" in
        dev)     env_code="d" ;;
        staging) env_code="s" ;;
        prod)    env_code="p" ;;
        *)       env_code="x" ;;
    esac
    
    local region_code
    case "$REGION" in
        eastus)     region_code="eus" ;;
        westus)     region_code="wus" ;;
        westeurope) region_code="weu" ;;
        northeurope) region_code="neu" ;;
        *)          region_code="xxx" ;;
    esac
    
    local timestamp=$(date +%Y%m%d)
    local random_suffix=$(cat /dev/urandom | tr -dc 'a-z0-9' | fold -w 4 | head -n 1)
    
    # Output JSON
    cat <<EOF
{
  "prefix": "cmp-${region_code}-${env_code}",
  "environment_code": "${env_code}",
  "region_code": "${region_code}",
  "timestamp": "${timestamp}",
  "random_suffix": "${random_suffix}",
  "resource_names": {
    "resource_group": "cmp-${region_code}-${env_code}-rg",
    "vnet": "cmp-${region_code}-${env_code}-vnet",
    "nsg_web": "cmp-${region_code}-${env_code}-web-nsg",
    "nsg_app": "cmp-${region_code}-${env_code}-app-nsg",
    "nsg_data": "cmp-${region_code}-${env_code}-dat-nsg",
    "storage": "cmp${region_code}${env_code}st${random_suffix}",
    "keyvault": "cmp-${region_code}-${env_code}-kv",
    "sql_server": "cmp-${region_code}-${env_code}-sql",
    "log_analytics": "cmp-${region_code}-${env_code}-law"
  }
}
EOF
}

# =============================================================================
# SECRETS FETCHER (Mock - would use Azure CLI in real scenario)
# =============================================================================
fetch_secrets() {
    log_info "Fetching secrets for environment: $ENVIRONMENT"
    
    # In production, this would call Azure Key Vault:
    # az keyvault secret show --vault-name "kv-${ENVIRONMENT}" --name "db-password" --query value -o tsv
    
    # Mock output for demonstration
    cat <<EOF
{
  "db_admin_password": "MOCK_PASSWORD_${ENVIRONMENT}_$(date +%s)",
  "storage_access_key": "MOCK_KEY_${ENVIRONMENT}",
  "api_key": "MOCK_API_KEY_${ENVIRONMENT}",
  "certificate_thumbprint": "MOCK_THUMBPRINT_${ENVIRONMENT}",
  "note": "In production, these would come from Azure Key Vault"
}
EOF
}

# =============================================================================
# IP RANGE CALCULATOR
# =============================================================================
calculate_ip_ranges() {
    local base_cidr
    case "$ENVIRONMENT" in
        dev)     base_cidr="10.0.0.0/16" ;;
        staging) base_cidr="10.1.0.0/16" ;;
        prod)    base_cidr="10.2.0.0/16" ;;
        *)       base_cidr="10.255.0.0/16" ;;
    esac
    
    # Calculate subnet CIDRs
    # This is simplified - real implementation would use ipcalc or similar
    local base_octet
    case "$ENVIRONMENT" in
        dev)     base_octet="0" ;;
        staging) base_octet="1" ;;
        prod)    base_octet="2" ;;
        *)       base_octet="255" ;;
    esac
    
    cat <<EOF
{
  "vnet_cidr": "10.${base_octet}.0.0/16",
  "subnets": {
    "web": {
      "cidr": "10.${base_octet}.0.0/24",
      "first_usable": "10.${base_octet}.0.4",
      "last_usable": "10.${base_octet}.0.254",
      "hosts": 251
    },
    "app": {
      "cidr": "10.${base_octet}.2.0/23",
      "first_usable": "10.${base_octet}.2.4",
      "last_usable": "10.${base_octet}.3.254",
      "hosts": 507
    },
    "data": {
      "cidr": "10.${base_octet}.4.0/24",
      "first_usable": "10.${base_octet}.4.4",
      "last_usable": "10.${base_octet}.4.254",
      "hosts": 251
    },
    "bastion": {
      "cidr": "10.${base_octet}.5.0/26",
      "first_usable": "10.${base_octet}.5.4",
      "last_usable": "10.${base_octet}.5.62",
      "hosts": 59
    },
    "gateway": {
      "cidr": "10.${base_octet}.5.64/26",
      "first_usable": "10.${base_octet}.5.68",
      "last_usable": "10.${base_octet}.5.126",
      "hosts": 59
    },
    "private_endpoints": {
      "cidr": "10.${base_octet}.10.0/24",
      "first_usable": "10.${base_octet}.10.4",
      "last_usable": "10.${base_octet}.10.254",
      "hosts": 251
    }
  }
}
EOF
}

# =============================================================================
# TIMESTAMP GENERATOR
# =============================================================================
generate_timestamps() {
    local current_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    local deployment_id=$(date +%Y%m%d%H%M%S)
    local week_number=$(date +%V)
    local fiscal_quarter=$(( ($(date +%-m) - 1) / 3 + 1 ))
    
    cat <<EOF
{
  "current_utc": "${current_time}",
  "deployment_id": "${deployment_id}",
  "week_number": "${week_number}",
  "fiscal_quarter": "Q${fiscal_quarter}",
  "fiscal_year": "FY$(date +%Y)",
  "tags": {
    "deployed_at": "${current_time}",
    "deployment_id": "deploy-${deployment_id}",
    "deployment_week": "W${week_number}",
    "fiscal_period": "FY$(date +%Y)-Q${fiscal_quarter}"
  }
}
EOF
}

# =============================================================================
# COMPLIANCE CHECKER
# =============================================================================
check_compliance() {
    local compliance_status="compliant"
    local issues=()
    
    # Check environment-specific compliance requirements
    case "$ENVIRONMENT" in
        prod)
            # Production requires stricter compliance
            if [[ "$REGION" == "westeurope" ]]; then
                log_info "GDPR compliance required for EU region"
            fi
            ;;
        dev)
            log_info "Development environment - relaxed compliance"
            ;;
    esac
    
    cat <<EOF
{
  "environment": "${ENVIRONMENT}",
  "region": "${REGION}",
  "compliance_status": "${compliance_status}",
  "frameworks": {
    "soc2": true,
    "hipaa": ${ENVIRONMENT:+false},
    "gdpr": $( [[ "$REGION" == *"europe"* ]] && echo "true" || echo "false" ),
    "pci_dss": $( [[ "$ENVIRONMENT" == "prod" ]] && echo "true" || echo "false" )
  },
  "requirements": {
    "encryption_at_rest": true,
    "encryption_in_transit": true,
    "mfa_required": $( [[ "$ENVIRONMENT" == "prod" ]] && echo "true" || echo "false" ),
    "audit_logging": true,
    "data_residency": "$( [[ "$REGION" == *"europe"* ]] && echo "EU" || echo "US" )"
  },
  "checked_at": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
}
EOF
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================
case "$CONFIG_TYPE" in
    naming)
        generate_naming
        ;;
    secrets)
        fetch_secrets
        ;;
    ip_ranges)
        calculate_ip_ranges
        ;;
    timestamps)
        generate_timestamps
        ;;
    compliance)
        check_compliance
        ;;
    *)
        log_error "Unknown config type: $CONFIG_TYPE"
        echo "Usage: $0 <naming|secrets|ip_ranges|timestamps|compliance> <environment> <region>"
        exit 1
        ;;
esac
