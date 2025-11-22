Here are all the essential **imperative commands** for Deployments, Pods, and Services:

## 🚀 **Deployment Imperative Commands**

### **Create Deployment**
```bash
# Basic deployment
kubectl create deployment <name> --image=<image>

# With replicas
kubectl create deployment <name> --image=<image> --replicas=3

# With port
kubectl create deployment <name> --image=<image> --port=8080

# With environment variables
kubectl create deployment <name> --image=<image> --env="KEY=VALUE"

# Multiple env vars
kubectl create deployment <name> --image=<image> \
  --env="DB_HOST=db" \
  --env="DB_PORT=5432"
```

### **Scale Deployment**
```bash
# Scale up/down
kubectl scale deployment <name> --replicas=5

# Scale based on current replicas
kubectl scale deployment <name> --current-replicas=2 --replicas=5
```

### **Update Deployment**
```bash
# Update image
kubectl set image deployment/<name> <container>=<new-image>

# Update environment variable
kubectl set env deployment/<name> KEY=VALUE

# Remove environment variable
kubectl set env deployment/<name> KEY-
```

### **Rollout Management**
```bash
# Check status
kubectl rollout status deployment/<name>

# Pause rollout
kubectl rollout pause deployment/<name>

# Resume rollout
kubectl rollout resume deployment/<name>

# Rollback to previous version
kubectl rollout undo deployment/<name>

# Rollback to specific revision
kubectl rollout undo deployment/<name> --to-revision=2

# View rollout history
kubectl rollout history deployment/<name>
```

### **Delete Deployment**
```bash
kubectl delete deployment <name>
```

## 📦 **Pod Imperative Commands**

### **Create Pod**
```bash
# Basic pod
kubectl run <pod-name> --image=<image>

# With labels
kubectl run <pod-name> --image=<image> --labels="app=web,env=prod"

# With environment variables
kubectl run <pod-name> --image=<image> --env="KEY=VALUE"

# With command
kubectl run <pod-name> --image=<image> --command -- <cmd> <arg1> <arg2>

# With port
kubectl run <pod-name> --image=<image> --port=8080

# With resource limits
kubectl run <pod-name> --image=<image> --limits="cpu=500m,memory=256Mi"

# With restart policy
kubectl run <pod-name> --image=<image> --restart=Never
```

### **Temporary Pods (for debugging)**
```bash
# Run and attach
kubectl run test --image=busybox --rm -it --restart=Never -- /bin/sh

# Run and sleep
kubectl run test --image=busybox --rm -it --restart=Never -- sleep 3600
```

### **Pod Operations**
```bash
# Execute command in pod
kubectl exec <pod-name> -- <command>

# Interactive shell
kubectl exec -it <pod-name> -- /bin/sh

# View logs
kubectl logs <pod-name>

# Follow logs
kubectl logs -f <pod-name>

# Copy files
kubectl cp <pod-name>:/path/to/file ./local-file
kubectl cp ./local-file <pod-name>:/path/to/file
```

### **Delete Pod**
```bash
kubectl delete pod <pod-name>

# Force delete
kubectl delete pod <pod-name> --force --grace-period=0
```

## 🌐 **Service Imperative Commands**

### **Create Service**
```bash
# ClusterIP service
kubectl create service clusterip <name> --tcp=80:8080

# NodePort service
kubectl create service nodeport <name> --tcp=80:8080

# LoadBalancer service
kubectl create service loadbalancer <name> --tcp=80:8080

# ExternalName service
kubectl create service externalname <name> --external-name=external.service.com

# Expose deployment as service
kubectl expose deployment <deployment-name> --port=80 --target-port=8080

# Expose with specific type
kubectl expose deployment <deployment-name> --type=NodePort --port=80 --target-port=8080

# Expose with labels selector
kubectl expose pod <pod-name> --port=80 --target-port=8080 --name=service-name
```

### **Service Operations**
```bash
# Get service details
kubectl describe service <name>

# Get service URL (for minikube/cloud)
minikube service <name> --url

# Patch service
kubectl patch service <name> -p '{"spec":{"type":"LoadBalancer"}}'
```

### **Delete Service**
```bash
kubectl delete service <name>
```

## ⚡ **Quick Examples**

### **Create Full App Stack Imperatively**
```bash
# Create deployment
kubectl create deployment webapp --image=nginx:alpine --replicas=3 --port=80

# Expose as service
kubectl expose deployment webapp --type=NodePort --port=80 --target-port=80

# Scale up
kubectl scale deployment webapp --replicas=5

# Update image
kubectl set image deployment/webapp nginx=nginx:latest

# Check everything
kubectl get all
```

### **Quick Debug Pod**
```bash
# Temporary debug pod
kubectl run debug --image=busybox --rm -it --restart=Never -- nslookup webapp

# Test service connectivity
kubectl run test --image=curlimages/curl --rm -it --restart=Never -- curl http://webapp:80
```

These imperative commands cover 95% of daily Kubernetes operations! 🚀