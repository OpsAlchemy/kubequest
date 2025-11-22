#!/bin/bash

# Create multi-host ingress
kubectl create ingress multi-host-ingress \
  --class=nginx \
  --rule="shop.example.com/*=shop-svc:80,tls=shop-tls" \
  --rule="blog.example.com/*=blog-svc:80,tls=blog-tls" \
  --dry-run=client -o yaml | kubectl apply -f -
