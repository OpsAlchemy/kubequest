#!/bin/bash

while sleep 0.3; do
  # Get the IP address correctly using command substitution
  IP=$(kubectl get ing app -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
  
  # Check if IP is not empty
  if [ -n "$IP" ]; then
    echo "Testing app.example.com on IP: $IP"
    curl -H "Host: app.example.com" http://${IP}
    echo -e "\n----------------------------------------"
  else
    echo "Waiting for IP address to be assigned..."
  fi
done
