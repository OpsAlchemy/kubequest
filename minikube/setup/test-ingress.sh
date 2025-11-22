#!/bin/bash
echo "Testing Ingress Controller..."
echo "Ingress IP: [0;34m[INFO][0m Waiting for Ingress Controller to get an external IP...
[0;32m[SUCCESS][0m Ingress Controller got external IP: 192.168.100.100
192.168.100.100"
echo ""
echo "Testing NGINX app (via path):"
curl -s http://[0;34m[INFO][0m Waiting for Ingress Controller to get an external IP...
[0;32m[SUCCESS][0m Ingress Controller got external IP: 192.168.100.100
192.168.100.100/app1 | grep -o "Welcome to nginx"
echo ""
echo "Testing Apache app (via path):"
curl -s http://[0;34m[INFO][0m Waiting for Ingress Controller to get an external IP...
[0;32m[SUCCESS][0m Ingress Controller got external IP: 192.168.100.100
192.168.100.100/app2 | grep -o "It works"
echo ""
echo "Testing direct access:"
curl -s http://[0;34m[INFO][0m Waiting for Ingress Controller to get an external IP...
[0;32m[SUCCESS][0m Ingress Controller got external IP: 192.168.100.100
192.168.100.100/app1
echo ""
