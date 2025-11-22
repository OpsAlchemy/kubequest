#!/usr/bin/env bash
set -euo pipefail

K="kubectl"
IMAGE="vikashraj1825/netkit"
REPLICAS="${REPLICAS:-1}"

usage(){
  cat <<EOF
Usage: $0 <up|down|status>

up      - create namespaces, deployments and services
down    - delete the namespaces (cleanup)
status  - show pods and services in created namespaces
EOF
  exit 1
}

# create a deployment + service for netkit
# args: name namespace text label_type label_value
create_app(){
  local name="$1"
  local namespace="$2"
  local text="$3"
  local label_type="$4"   # e.g. "tenant" or "shared"
  local label_value="$5"  # e.g. "alpha" or "true"

  kubectl apply -n "${namespace}" -f - <<YAML
apiVersion: v1
kind: Service
metadata:
  name: ${name}
  labels:
    app: ${name}
    ${label_type}: "${label_value}"
spec:
  type: ClusterIP
  selector:
    app: ${name}
  ports:
  - port: 80
    targetPort: 80
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
  labels:
    app: ${name}
    ${label_type}: "${label_value}"
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: ${name}
  template:
    metadata:
      labels:
        app: ${name}
        ${label_type}: "${label_value}"
    spec:
      containers:
      - name: ${name}
        image: ${IMAGE}
        # DO NOT override CMD: use image default start.sh which keeps the container alive
        env:
        - name: TEXT
          value: "${text}"
        - name: PORT
          value: "80"
        ports:
        - containerPort: 80
YAML
}


cmd_up(){
  # create namespaces (idempotent)
  ${K} apply -f - <<YAML
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-a
  labels:
    platform: tenant
    tenant: alpha
---
apiVersion: v1
kind: Namespace
metadata:
  name: tenant-b
  labels:
    platform: tenant
    tenant: beta
---
apiVersion: v1
kind: Namespace
metadata:
  name: shared-services
  labels:
    platform: shared
    shared: "true"
YAML

  # tenant-a apps
  # web-app (app=web, tenant=alpha)
  create_app web-app tenant-a "web-app - Company Alpha" tenant alpha
  # backend (app=api, tenant=alpha)
  create_app backend tenant-a "backend - Company Alpha" tenant alpha
  # database (app=database, tenant=alpha)
  create_app database tenant-a "database - Company Alpha" tenant alpha

  # tenant-b apps (labels tenant=beta)
  create_app web-app tenant-b "web-app - Company Beta" tenant beta
  create_app backend tenant-b "backend - Company Beta" tenant beta
  create_app database tenant-b "database - Company Beta" tenant beta

  # shared services (labels shared=true)
  create_app auth-service shared-services "auth-service - platform" shared "true"
  create_app notification shared-services "notification - platform" shared "true"

  echo "✅ up complete. Run: ${K} get pods -A  OR ./sol.sh status"
}

cmd_down(){
  echo "Deleting namespaces (this deletes contained resources)..."
  ${K} delete namespace tenant-a tenant-b shared-services --ignore-not-found
  echo "🗑️  teardown requested"
}

cmd_status(){
  for ns in tenant-a tenant-b shared-services; do
    echo "---- ${ns} ----"
    ${K} -n "${ns}" get pods -o wide || true
    ${K} -n "${ns}" get svc || true
    echo
  done
}

case "${1:-}" in
  up) cmd_up ;;
  down) cmd_down ;;
  status) cmd_status ;;
  *) usage ;;
esac

