#!/bin/bash

# Create SSL certificates
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out shop.crt -keyout shop.key -subj "/CN=shop.example.com"

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -out blog.crt -keyout blog.key -subj "/CN=blog.example.com"

# Create Kubernetes secrets
kubectl create secret tls shop-tls --cert=shop.crt --key=shop.key
kubectl create secret tls blog-tls --cert=blog.crt --key=blog.key

# Clean up temporary files (optional)
rm shop.crt shop.key blog.crt blog.key
