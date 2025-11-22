#!/usr/bin/env bash
set -euo pipefail

K="kubectl"

# You can override these env vars before running the script
FRONTEND_TEXT="${FRONTEND_TEXT:-This is frontend}"
BACKEND_TEXT="${BACKEND_TEXT:-This is backend}"
DATABASE_TEXT="${DATABASE_TEXT:-This is database}"
REPLICAS="${REPLICAS:-2}"
TARGET_PORT="${TARGET_PORT:-5678}"   # http-echo default
SERVICE_PORT="${SERVICE_PORT:-80}"

# Debug image: change to "alpine:3.19" if you prefer smaller image (see note below)
DEBUG_IMAGE="${DEBUG_IMAGE:-nicolaka/netshoot:latest}"
# If you want tiny image + curl installed on startup instead, use:
# DEBUG_IMAGE="alpine:3.19"

create_deploy_manifest() {
  local name="$1"
  local text="$2"
  local replicas="$3"
  cat <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
spec:
  replicas: ${replicas}
  selector:
    matchLabels:
      app: acme
      tier: ${name}
  template:
    metadata:
      labels:
        app: acme
        tier: ${name}
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text", "${text}", "-listen", ":${TARGET_PORT}"]
        ports:
        - containerPort: ${TARGET_PORT}
      - name: debug
        image: ${DEBUG_IMAGE}
        # For netshoot this will give you bash + networking tools.
        # If you switch to alpine and want curl, uncomment the command below:
        # command: ["sh", "-c", "apk add --no-cache curl && sleep 1d"]
        command: ["sleep", "1d"]
EOF
}

create_service_manifest() {
  local name="$1"
  cat <<EOF
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: acme
    tier: ${name}
  ports:
  - protocol: TCP
    port: ${SERVICE_PORT}
    targetPort: ${TARGET_PORT}
  type: ClusterIP
EOF
}

# Apply
echo "Applying deployments with debug sidecar (${DEBUG_IMAGE})..."
create_deploy_manifest frontend "${FRONTEND_TEXT}" "${REPLICAS}" | ${K} apply -f -
create_service_manifest frontend | ${K} apply -f -

create_deploy_manifest backend "${BACKEND_TEXT}" "${REPLICAS}" | ${K} apply -f -
create_service_manifest backend | ${K} apply -f -

create_deploy_manifest database "${DATABASE_TEXT}" "${REPLICAS}" | ${K} apply -f -
create_service_manifest database | ${K} apply -f -

# Ensure labels (keeps parity with your earlier script)
${K} label deploy frontend app=acme tier=frontend --overwrite || true
${K} label deploy backend app=acme tier=backend --overwrite || true
${K} label deploy database app=acme tier=database --overwrite || true

echo "Waiting for rollout..."
${K} rollout status deploy/frontend
${K} rollout status deploy/backend
${K} rollout status deploy/database

cat <<'EOF'

All done.

Examples — how to use the debug sidecar (with curl present):

# 1) Exec into debug container (netshoot has bash)
POD=$(${K} get pods -l app=acme,tier=frontend -o jsonpath='{.items[0].metadata.name}')
kubectl exec -it $POD -c debug -- bash

# inside the debug shell you'll have curl, dig, tcpdump, etc.
# Example:
curl http://backend:80    # hits the backend Service from inside the cluster
curl http://database:80   # hits the database Service

# 2) Port-forward frontend Service to local machine and curl locally
kubectl port-forward svc/frontend ${SERVICE_PORT}:${SERVICE_PORT} &
curl http://127.0.0.1:${SERVICE_PORT}

# 3) If you already deployed and just want to replace the debug image in-place:
kubectl set image deployment/frontend debug=${DEBUG_IMAGE}
kubectl set image deployment/backend debug=${DEBUG_IMAGE}
kubectl set image deployment/database debug=${DEBUG_IMAGE}

EOF

