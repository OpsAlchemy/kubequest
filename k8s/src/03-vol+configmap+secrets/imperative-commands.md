Certainly! Here are all the essential **imperative commands** for ConfigMaps and Secrets in Kubernetes:

## 🔧 **ConfigMap Imperative Commands**

### **Create ConfigMap**
```bash
# From literal values
kubectl create configmap <name> --from-literal=<key>=<value>

# From file
kubectl create configmap <name> --from-file=<path-to-file>

# From directory (all files)
kubectl create configmap <name> --from-file=<directory-path>

# From env file
kubectl create configmap <name> --from-env-file=<path-to-env-file>

# Multiple sources
kubectl create configmap <name> \
  --from-literal=key1=value1 \
  --from-literal=key2=value2 \
  --from-file=config.properties
```

### **Update ConfigMap**
```bash
# Update from literal
kubectl create configmap <name> --from-literal=<key>=<new-value> --dry-run=client -o yaml | kubectl apply -f -

# Update from file
kubectl create configmap <name> --from-file=<new-file> --dry-run=client -o yaml | kubectl apply -f -
```

### **View ConfigMaps**
```bash
# List all ConfigMaps
kubectl get configmaps

# Describe ConfigMap
kubectl describe configmap <name>

# Get ConfigMap as YAML
kubectl get configmap <name> -o yaml

# Get specific key value
kubectl get configmap <name> -o jsonpath='{.data.<key>}'
```

### **Delete ConfigMap**
```bash
kubectl delete configmap <name>
```

## 🔐 **Secret Imperative Commands**

### **Create Generic Secrets**
```bash
# From literal values
kubectl create secret generic <name> --from-literal=<key>=<value>

# From file
kubectl create secret generic <name> --from-file=<path-to-file>

# Multiple literals
kubectl create secret generic <name> \
  --from-literal=username=admin \
  --from-literal=password=secret

# Specify type explicitly
kubectl create secret generic <name> --type=kubernetes.io/tls
```

### **Create TLS Secrets**
```bash
# From certificate files
kubectl create secret tls <name> \
  --cert=<path-to-cert> \
  --key=<path-to-key>
```

### **Create Docker Registry Secrets**
```bash
# For image pull secrets
kubectl create secret docker-registry <name> \
  --docker-server=<registry-server> \
  --docker-username=<username> \
  --docker-password=<password> \
  --docker-email=<email>
```

### **View Secrets**
```bash
# List all secrets
kubectl get secrets

# Describe secret
kubectl describe secret <name>

# Get secret as YAML (encoded)
kubectl get secret <name> -o yaml

# Decode specific secret value
kubectl get secret <name> -o jsonpath='{.data.<key>}' | base64 -d
```

### **Update Secrets**
```bash
# Update secret value
kubectl create secret generic <name> --from-literal=<key>=<new-value> --dry-run=client -o yaml | kubectl apply -f -
```

### **Delete Secrets**
```bash
kubectl delete secret <name>
```

## ⚡ **Quick Examples**

### **Create ConfigMap from environment file**
```bash
kubectl create configmap app-config --from-env-file=.env
```

### **Create Secret with multiple values**
```bash
kubectl create secret generic db-credentials \
  --from-literal=db-user=admin \
  --from-literal=db-password=secret123
```

### **Decode and view secret data**
```bash
kubectl get secret my-secret -o jsonpath='{.data.username}' | base64 -d
```

### **Update ConfigMap imperatively**
```bash
kubectl create configmap my-config --from-literal=version=2.0 --dry-run=client -o yaml | kubectl apply -f -
```