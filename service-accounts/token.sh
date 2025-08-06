
#!/bin/bash

SERVICE_ACCOUNT_NAME="external-access"
NAMESPACE="default"

# Request a token using raw TokenRequest API
SERVICE_ACCOUNT_TOKEN=$(kubectl create -f - --raw /api/v1/namespaces/${NAMESPACE}/serviceaccounts/${SERVICE_ACCOUNT_NAME}/token <<EOF | jq -r .status.token
{
  "apiVersion": "authentication.k8s.io/v1",
  "kind": "TokenRequest",
  "spec": {
    "audiences": ["https://kubernetes.default.svc.cluster.local"],
    "expirationSeconds": 7200
  }
}
EOF
)

# Export so it can be used in this shell
export SERVICE_ACCOUNT_TOKEN

# Confirm it's set
echo "Token exported to \$SERVICE_ACCOUNT_TOKEN"

