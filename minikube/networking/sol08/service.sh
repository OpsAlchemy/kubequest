#!/bin/bash

# Expose services
kubectl expose deploy shop-app --name=shop-svc --port=80 --target-port=80 --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy blog-app --name=blog-svc --port=80 --target-port=80 --dry-run=client -o yaml | kubectl apply -f -
