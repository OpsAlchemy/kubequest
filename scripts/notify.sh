#!/bin/bash
# =============================================================================
# NOTIFICATION SCRIPT - Post-deployment notifications
# =============================================================================
# Called by Terragrunt after_hook to send deployment notifications
# =============================================================================

set -euo pipefail

ACTION="${1:-apply}"
ENVIRONMENT="${2:-dev}"
STATUS="${3:-success}"
MODULE="${4:-unknown}"

BLUE='\033[0;34m'
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
DEPLOYMENT_ID="deploy-$(date +%Y%m%d%H%M%S)"
USER=$(whoami)
HOSTNAME=$(hostname)

echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}  DEPLOYMENT NOTIFICATION${NC}"
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
echo ""

# Build notification payload
PAYLOAD=$(cat <<EOF
{
  "deployment_id": "${DEPLOYMENT_ID}",
  "timestamp": "${TIMESTAMP}",
  "environment": "${ENVIRONMENT}",
  "module": "${MODULE}",
  "action": "${ACTION}",
  "status": "${STATUS}",
  "triggered_by": "${USER}@${HOSTNAME}",
  "details": {
    "terraform_version": "$(terraform version -json 2>/dev/null | jq -r '.terraform_version' 2>/dev/null || echo 'unknown')",
    "terragrunt_version": "$(terragrunt --version 2>/dev/null | head -1 || echo 'unknown')",
    "working_directory": "$(pwd)",
    "git_branch": "$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo 'unknown')",
    "git_commit": "$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')"
  }
}
EOF
)

echo "Notification Payload:"
echo "$PAYLOAD" | jq '.' 2>/dev/null || echo "$PAYLOAD"
echo ""

# =============================================================================
# NOTIFICATION CHANNELS (Mock implementations)
# =============================================================================

# Slack notification (mock)
send_slack_notification() {
    echo -e "${BLUE}[Slack]${NC} Would send notification to #deployments channel"
    # In production:
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "$PAYLOAD" \
    #   https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK
}

# Teams notification (mock)
send_teams_notification() {
    echo -e "${BLUE}[Teams]${NC} Would send notification to Deployments team"
    # In production:
    # curl -X POST -H 'Content-type: application/json' \
    #   --data "$PAYLOAD" \
    #   https://outlook.office.com/webhook/YOUR/TEAMS/WEBHOOK
}

# Email notification (mock)
send_email_notification() {
    echo -e "${BLUE}[Email]${NC} Would send email to platform-team@company.com"
    # In production:
    # sendmail or similar
}

# PagerDuty notification (for failures in prod)
send_pagerduty_notification() {
    if [[ "$STATUS" == "failure" && "$ENVIRONMENT" == "prod" ]]; then
        echo -e "${RED}[PagerDuty]${NC} Would trigger incident for production failure"
        # In production:
        # curl -X POST -H 'Content-type: application/json' \
        #   --data "$PAYLOAD" \
        #   https://events.pagerduty.com/v2/enqueue
    fi
}

# Azure DevOps notification
send_azdo_notification() {
    echo -e "${BLUE}[Azure DevOps]${NC} Would update deployment status in pipeline"
    # In production:
    # az pipelines runs update ...
}

# =============================================================================
# SEND NOTIFICATIONS BASED ON ENVIRONMENT
# =============================================================================

case "$ENVIRONMENT" in
    prod)
        echo -e "\n${BLUE}Sending production notifications...${NC}"
        send_slack_notification
        send_teams_notification
        send_email_notification
        send_pagerduty_notification
        send_azdo_notification
        ;;
    staging)
        echo -e "\n${BLUE}Sending staging notifications...${NC}"
        send_slack_notification
        send_teams_notification
        ;;
    dev)
        echo -e "\n${BLUE}Sending dev notifications...${NC}"
        send_slack_notification
        ;;
esac

# =============================================================================
# LOG TO FILE
# =============================================================================

LOG_DIR="${HOME}/.terragrunt/logs"
mkdir -p "$LOG_DIR"
LOG_FILE="${LOG_DIR}/deployments.log"

echo "${TIMESTAMP} | ${DEPLOYMENT_ID} | ${ENVIRONMENT} | ${MODULE} | ${ACTION} | ${STATUS} | ${USER}" >> "$LOG_FILE"
echo -e "\n${GREEN}Notification logged to: ${LOG_FILE}${NC}"

echo ""
echo -e "${BLUE}═══════════════════════════════════════════════════════════════${NC}"
