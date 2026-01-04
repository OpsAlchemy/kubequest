# Verify template rendering
helm template my-app . --debug

# Dry-run install
helm install --dry-run my-app .

# Real install
helm install my-app .

# Verify resources
kubectl get deployment,service
kubectl logs deployment/my-app-webapp

# Scale up
helm upgrade my-app . --set replicaCount=3
kubectl get pods
---
