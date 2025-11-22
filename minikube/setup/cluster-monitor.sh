#!/bin/bash

echo "=== Minikube Cluster Monitor ==="
echo "Timestamp: $(date)"
echo ""

echo "📊 Node Status:"
kubectl get nodes -o wide
echo ""

echo "📈 Node Metrics:"
kubectl top nodes --use-protocol-buffers 2>/dev/null || kubectl top nodes 2>/dev/null || echo "Metrics not available yet"
echo ""

echo "🐳 Pod Distribution:"
kubectl get pods -A -o wide | awk '{print $1,$2,$3,$4,$7}' | column -t
echo ""

echo "🔧 Cluster Info:"
minikube status --profile=minikube-calico
echo ""

echo "🌐 Services:"
kubectl get svc -A | grep -v none | column -t
