#!/bin/bash

case "$1" in
    "apply")
        echo "Creating TLS secrets..."
        bash secret.sh
        
        echo "Creating deployments..."
        bash deployments.sh
        
        echo "Waiting for deployments to be ready..."
        kubectl rollout status deploy shop-app --timeout=120s
        kubectl rollout status deploy blog-app --timeout=120s
        
        echo "Creating services..."
        bash services.sh
        
        echo "Creating ingress..."
        bash ingress.sh
        
        echo "Setup completed successfully!"
        ;;
    "delete")
        echo "Cleaning up resources..."
        kubectl delete ingress multi-host-ingress 2>/dev/null || true
        kubectl delete svc blog-svc shop-svc 2>/dev/null || true
        kubectl delete deploy blog-app shop-app 2>/dev/null || true
        kubectl delete secret blog-tls shop-tls 2>/dev/null || true
        echo "Cleanup completed!"
        ;;
    *)
        echo "Usage: $0 {apply|delete}"
        exit 1
        ;;
esac
