#!/bin/bash

DROPLET_IP=$(terraform -chdir=/workspaces/kubequest/k8s-single-node/infra output -raw droplet_ip)

KEY_PATH="/workspaces/kubequest/k8s-single-node/infra/keys/id_rsa"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "❌ SSH key not found at $KEY_PATH"
  exit 1
fi

ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no root@$DROPLET_IP
