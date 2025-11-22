#!/bin/bash

while sleep 2; do
  IP=$(kubectl get ing main -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  
  # Check if IP is not empty
  if [ -n "$IP" ]; then
    echo "Testing app.example.com on IP: $IP"
    curl --insecure -H "Host: app.example.com" https://${IP}
    echo -e "\n----------------------------------------"
  else
    echo "Waiting for IP address to be assigned..."
  fi
done
