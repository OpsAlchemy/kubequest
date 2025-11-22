#!/bin/bash
# cleanup-ingress.sh

set -e

INGRESS_NAMESPACE="ingress-nginx"
TRAEFIK_NAMESPACE="traefik"
TEST_NAMESPACE="ingress-test"

echo "Cleaning up Ingress Controller setup..."

# Delete test namespace and resources
kubectl delete namespace "$TEST_NAMESPACE" 2>/dev/null || true

# Delete NGINX Ingress
helm uninstall ingress-nginx -n "$INGRESS_NAMESPACE" 2>/dev/null || true
kubectl delete namespace "$INGRESS_NAMESPACE" 2>/dev/null || true

# Delete Traefik Ingress
helm uninstall traefik -n "$TRAEFIK_NAMESPACE" 2>/dev/null || true
kubectl delete namespace "$TRAEFIK_NAMESPACE" 2>/dev/null || true

# Delete any remaining ingress resources
kubectl delete ingress -A --all 2>/dev/null || true

# Remove test script
rm -f test-ingress.sh

echo "Ingress Controller cleanup completed!"
