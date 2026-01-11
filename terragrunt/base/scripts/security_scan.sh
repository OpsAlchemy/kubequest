#!/bin/bash
# =============================================================================
# SECURITY SCANNER - Pre-deployment security checks
# =============================================================================
# Called by Terragrunt before_hook to validate security compliance
# =============================================================================

set -euo pipefail

PLAN_FILE="${1:-}"
ENVIRONMENT="${2:-dev}"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  SECURITY SCANNER - Pre-deployment Validation${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

ERRORS=0
WARNINGS=0

check_pass() {
    echo -e "  ${GREEN}✓${NC} $1"
}

check_fail() {
    echo -e "  ${RED}✗${NC} $1"
    ((ERRORS++))
}

check_warn() {
    echo -e "  ${YELLOW}⚠${NC} $1"
    ((WARNINGS++))
}

# =============================================================================
# TERRAFORM CONFIGURATION CHECKS
# =============================================================================
echo -e "${BLUE}[1/5] Checking Terraform Configuration...${NC}"

# Check for hardcoded secrets
if grep -rn "password\s*=\s*\"[^\"]*\"" *.tf 2>/dev/null | grep -v "var\." | grep -v "local\." > /dev/null; then
    check_fail "Hardcoded passwords found in .tf files"
else
    check_pass "No hardcoded passwords detected"
fi

# Check for hardcoded API keys
if grep -rn "api_key\|secret_key\|access_key" *.tf 2>/dev/null | grep -v "var\." | grep -v "local\." | grep -v "data\." > /dev/null; then
    check_warn "Potential hardcoded API keys found"
else
    check_pass "No hardcoded API keys detected"
fi

# =============================================================================
# AZURE SECURITY BEST PRACTICES
# =============================================================================
echo ""
echo -e "${BLUE}[2/5] Checking Azure Security Best Practices...${NC}"

# Check for public IP assignments in production
if [[ "$ENVIRONMENT" == "prod" ]]; then
    if grep -rn "azurerm_public_ip" *.tf 2>/dev/null > /dev/null; then
        check_warn "Public IPs defined in production environment"
    else
        check_pass "No public IPs in production"
    fi
fi

# Check for HTTPS enforcement
if grep -rn "enable_https_traffic_only\s*=\s*false" *.tf 2>/dev/null > /dev/null; then
    check_fail "HTTPS-only traffic is disabled on some storage accounts"
else
    check_pass "HTTPS-only traffic is enforced"
fi

# Check for TLS version
if grep -rn "min_tls_version\s*=\s*\"TLS1_0\|TLS1_1\"" *.tf 2>/dev/null > /dev/null; then
    check_fail "Legacy TLS versions (1.0/1.1) are allowed"
else
    check_pass "TLS 1.2 minimum is enforced"
fi

# =============================================================================
# NETWORK SECURITY CHECKS
# =============================================================================
echo ""
echo -e "${BLUE}[3/5] Checking Network Security...${NC}"

# Check for overly permissive NSG rules
if grep -rn "source_address_prefix\s*=\s*\"\*\"" *.tf 2>/dev/null | grep -v "Deny" > /dev/null; then
    check_warn "NSG rules with wildcard source addresses found"
else
    check_pass "No overly permissive NSG rules"
fi

# Check for public network access
if grep -rn "public_network_access_enabled\s*=\s*true" *.tf 2>/dev/null > /dev/null; then
    if [[ "$ENVIRONMENT" == "prod" ]]; then
        check_fail "Public network access enabled in production"
    else
        check_warn "Public network access enabled"
    fi
else
    check_pass "Public network access is disabled"
fi

# =============================================================================
# ENCRYPTION CHECKS
# =============================================================================
echo ""
echo -e "${BLUE}[4/5] Checking Encryption Settings...${NC}"

# Check for encryption at rest
if grep -rn "encryption_state\s*=\s*\"Disabled\"" *.tf 2>/dev/null > /dev/null; then
    check_fail "Encryption at rest is disabled on some resources"
else
    check_pass "Encryption at rest is enabled"
fi

# Check for CMK in production
if [[ "$ENVIRONMENT" == "prod" ]]; then
    if grep -rn "customer_managed_key" *.tf 2>/dev/null > /dev/null; then
        check_pass "Customer-managed keys are configured"
    else
        check_warn "Customer-managed keys not found in production"
    fi
fi

# =============================================================================
# COMPLIANCE CHECKS
# =============================================================================
echo ""
echo -e "${BLUE}[5/5] Checking Compliance Requirements...${NC}"

# Check for required tags
REQUIRED_TAGS=("environment" "owner" "cost_center" "managed_by")
for tag in "${REQUIRED_TAGS[@]}"; do
    if grep -rn "\"$tag\"" *.tf 2>/dev/null > /dev/null; then
        check_pass "Required tag '$tag' is present"
    else
        check_warn "Required tag '$tag' may be missing"
    fi
done

# =============================================================================
# SUMMARY
# =============================================================================
echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  SCAN SUMMARY${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "  ${RED}ERRORS:   $ERRORS${NC}"
fi
if [[ $WARNINGS -gt 0 ]]; then
    echo -e "  ${YELLOW}WARNINGS: $WARNINGS${NC}"
fi

if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "  ${GREEN}All security checks passed!${NC}"
fi

echo ""

# Exit with error if critical issues found
if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}Security scan failed with $ERRORS error(s). Deployment blocked.${NC}"
    exit 1
fi

if [[ $WARNINGS -gt 0 ]]; then
    echo -e "${YELLOW}Security scan completed with $WARNINGS warning(s). Review recommended.${NC}"
fi

exit 0
