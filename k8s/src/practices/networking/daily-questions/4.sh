#!/usr/bin/env bash
set -euo pipefail

K=kubectl
NS="${1:-playground}"
IMAGE="hashicorp/http-echo"

items=(
  "deploy-name=blue-app;service-name=blue-svc;port=5678;target-port=5678"
  "deploy-name=red-app;service-name=red-svc;port=5678;target-port=5678"
)

$K get ns "$NS" >/dev/null 2>&1 || $K create ns "$NS"

for item in "${items[@]}"; do
  declare -A obj=()
  IFS=';' read -ra pairs <<< "$item"
  for p in "${pairs[@]}"; do
    IFS='=' read -r k v <<< "$p"
    obj[$k]=$v
  done

  dep="${obj[deploy-name]}"
  svc="${obj[service-name]}"
  port="${obj[port]}"
  tport="${obj[target-port]}"

  cat <<EOF | $K apply -n "$NS" -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${dep}
  labels:
    app: ${dep}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${dep}
  template:
    metadata:
      labels:
        app: ${dep}
    spec:
      containers:
      - name: http-echo
        image: ${IMAGE}
        args: ["-text","Hello from ${dep}"]
        ports:
        - containerPort: ${tport}
EOF

  $K expose deployment "$dep" --name="$svc" --port="$port" --target-port="$tport" --type=ClusterIP --dry-run=client -o yaml | $K apply -n "$NS" -f -

  $K -n "$NS" rollout status deployment/"$dep" --timeout=120s
done

$K -n "$NS" get deploy,svc -o wide
k create ingress color-ingress --class=nginx --rule=red.example.com/*=red-svc:5678 --rule=blue.example.com/*=blue-svc:5678 --dry-run=client -o yaml | k apply -f -
