#!/bin/bash

# Script to generate TLS cert/key and create a Kubernetes ConfigMap
set -e # Exit on any error

# Configuration
KEY_FILE="server.key"
CRT_FILE="server.crt"
CONFIGMAP_NAME="tls-secrets"
NAMESPACE="default" # Change if needed
DAYS_VALID=365

echo "Generating TLS private key and self-signed certificate..."

# Generate the key and certificate in one step
openssl req -x509 -newkey rsa:4096 \
  -keyout "$KEY_FILE" \
  -out "$CRT_FILE" \
  -days "$DAYS_VALID" \
  -nodes \
  -subj "/CN=localhost/O=My Local Dev" 2>/dev/null

echo "Generated $KEY_FILE and $CRT_FILE"

# Verify the files were created
if [[ ! -f "$KEY_FILE" || ! -f "$CRT_FILE" ]]; then
    echo "Error: Failed to generate TLS files"
    exit 1
fi

echo "Creating Kubernetes ConfigMap from the TLS files..."

# Create the ConfigMap
kubectl create configmap "$CONFIGMAP_NAME" \
  --namespace "$NAMESPACE" \
  --from-file="$KEY_FILE" \
  --from-file="$CRT_FILE" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "ConfigMap '$CONFIGMAP_NAME' created in namespace '$NAMESPACE'"

# Optional: Verify the ConfigMap
echo "Verifying ConfigMap contents..."
kubectl get configmap "$CONFIGMAP_NAME" --namespace "$NAMESPACE" -o jsonpath='{.data}' | jq 'keys'

echo "Done! Files are ready for use in your pods."
