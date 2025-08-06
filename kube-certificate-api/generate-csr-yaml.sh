#!/bin/bash

CSR_NAME="maria"
KEY_FILE="${CSR_NAME}.key"
CSR_FILE="${CSR_NAME}.csr"
YAML_FILE="${CSR_NAME}-csr.yaml"

# Generate private key if not exists
[[ -f "$KEY_FILE" ]] || openssl genrsa -out "$KEY_FILE" 2048

# Generate CSR
openssl req -new -key "$KEY_FILE" -subj "/CN=$CSR_NAME" -out "$CSR_FILE"

# Encode CSR in base64 (single-line)
CSR_B64=$(base64 -w 0 "$CSR_FILE")  # Use `-b 0` on macOS

# Generate CSR YAML
cat <<EOF > "$YAML_FILE"
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $CSR_NAME
spec:
  groups:
    - system:authenticated
  request: $CSR_B64
  signerName: kubernetes.io/kube-apiserver-client
  usages:
    - client auth
EOF

echo "[✓] Generated $YAML_FILE"

