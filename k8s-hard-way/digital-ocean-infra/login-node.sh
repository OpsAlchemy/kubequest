#!/bin/bash

KEY_PATH="./keys/id_rsa"
NODE="$1"

if [[ "$NODE" != "master" && "$NODE" != "worker" ]]; then
  echo "Usage: login-node.sh [master|worker]"
  exit 1
fi

# Get IP from Terraform outputs
IP=$(terraform output -raw ${NODE}_public_ip 2>/dev/null)

if [ -z "$IP" ]; then
  echo "[ERROR] Could not get IP for $NODE via terraform output."
  exit 2
fi

echo "[INFO] Connecting to $NODE ($IP)..."
ssh -i "$KEY_PATH" root@"$IP"

