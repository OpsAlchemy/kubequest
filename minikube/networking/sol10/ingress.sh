#!/bin/bash

# Delete existing ingresses
kubectl delete ingress main canary 2>/dev/null || true

# Create main ingress (100% to v1) - NO TLS, correct port 80
kubectl create ingress main --class=nginx \
  --rule="app.example.com/*=web-v1-svc:80" \
  --dry-run=client -o yaml | kubectl apply -f -

# Create canary ingress (20% to v2) - NO TLS, correct port 80, same pathType
kubectl create ingress canary --class=nginx \
  --rule="app.example.com/*=web-v2-svc:80" \
  --annotation="nginx.ingress.kubernetes.io/canary=true" \
  --annotation="nginx.ingress.kubernetes.io/canary-weight=90" \
  --dry-run=client -o yaml | kubectl apply -f -
