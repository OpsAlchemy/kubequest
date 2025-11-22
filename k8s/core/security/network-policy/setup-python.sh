#!/bin/bash
# setup.sh: network policy lab with full-toolbox pods
# Each pod runs Python HTTP server and has a bunch of networking tools installed.

NAMESPACE=netpol-lab
COMPONENTS=("frontend:80:ui" "backend:8080:api" "db:80:data")

TOOLS="bash curl wget bind-tools iproute2 tcpdump socat netcat-openbsd busybox-extras"

create_all() {
  echo "[+] Creating namespace $NAMESPACE..."
  kubectl create ns $NAMESPACE 2>/dev/null || true
  kubectl label ns $NAMESPACE purpose=netpol --overwrite

  echo "[+] Creating pods and services..."
  for entry in "${COMPONENTS[@]}"; do
    IFS=":" read -r comp port tier <<< "$entry"

    echo "[+] Creating $comp on port $port with all tools..."
    kubectl run $comp --image=python:3-alpine -n $NAMESPACE --restart=Never \
      --labels="app=$comp,tier=$tier" \
      -- sh -c "apk add --no-cache $TOOLS >/dev/null && python3 -m http.server $port"
    
    kubectl expose pod $comp --port=$port -n $NAMESPACE --name=$comp
  done

  echo "[+] Setup complete."
}

delete_all() {
  echo "[+] Deleting pods and services in $NAMESPACE..."
  for entry in "${COMPONENTS[@]}"; do
    IFS=":" read -r comp _ <<< "$entry"
    kubectl delete pod $comp -n $NAMESPACE --ignore-not-found
    kubectl delete svc $comp -n $NAMESPACE --ignore-not-found
  done
}

status_all() {
  echo "[+] Pods in $NAMESPACE:"
  kubectl get pods -n $NAMESPACE -o wide --show-labels
  echo
  echo "[+] Services in $NAMESPACE:"
  kubectl get svc -n $NAMESPACE --show-labels
  echo
  echo "[+] Namespace labels:"
  kubectl get ns $NAMESPACE --show-labels
}

case "$1" in
  up)
    create_all
    ;;
  down)
    delete_all
    ;;
  status)
    status_all
    ;;
  *)
    echo "Usage: $0 {up|down|status}"
    exit 1
    ;;
esac
