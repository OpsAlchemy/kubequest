#!/bin/bash

TF_WORKSPACE="/workspaces/kubequest/k8s-single-node/infra"
KEY_PATH="$TF_WORKSPACE/keys/id_rsa"

if [[ ! -f "$KEY_PATH" ]]; then
  echo "SSH key not found: $KEY_PATH"
  exit 1
fi

case "$1" in
  single)
    DROPLET_IP=$(terraform -chdir="$TF_WORKSPACE" output -raw droplet_ip)
    ;;
  db)
    DROPLET_IP=$(terraform -chdir="$TF_WORKSPACE" output -raw droplet_ip_db)
    ;;
  worker-1)
    DROPLET_IP=$(terraform -chdir="$TF_WORKSPACE" output -raw droplet_ip_worker_1)
    ;;
  *)
    echo "Usage: $0 {single|db|worker-1}"
    exit 1
    ;;
esac

if [[ -z "$DROPLET_IP" ]]; then
  echo "IP not found for selection: $1"
  exit 1
fi

ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no root@"$DROPLET_IP"