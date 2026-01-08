# **Helm Comprehensive Guide**

## **TABLE OF CONTENTS**
1. [Helm Fundamentals](#1-helm-fundamentals)
2. [Repository Management](#2-repository-management)
3. [Release Lifecycle](#3-release-lifecycle)
4. [Configuration Management](#4-configuration-management)
5. [Advanced Operations](#5-advanced-operations)
6. [Debugging & Troubleshooting](#6-debugging--troubleshooting)
7. [Best Practices](#7-best-practices)
8. [Real-world Examples](#8-real-world-examples)

---

## **1. HELM FUNDAMENTALS**

### **What is Helm?**
Helm is the **package manager for Kubernetes**, allowing you to:
- Define, install, and upgrade Kubernetes applications
- Package applications as charts
- Manage dependencies between applications
- Share applications through repositories

### **Key Concepts**

| Concept | Description | Example |
|---------|-------------|---------|
| **Chart** | Package containing all resource definitions | `bitnami/mysql`, `nginx-ingress` |
| **Release** | Instance of a chart running in Kubernetes | `mysql-release`, `webapp-prod` |
| **Repository** | Collection of charts | `bitnami`, `stable`, `jetstack` |
| **Values** | Configurable parameters for a chart | Database passwords, replica counts |

### **Version Types**
```bash
# Chart outputs show both versions:
CHART NAME: tomcat
CHART VERSION: 13.3.0    # ← Helm chart version (templates/config)
APP VERSION: 11.0.15     # ← Application version (actual software)
```

**Key Difference:**
- **Chart Version**: Changes when Helm templates, dependencies, or configurations change
- **App Version**: Changes when the actual application software version changes

---

## **2. REPOSITORY MANAGEMENT**

### **Core Commands**

```bash
# Add a repository
helm repo add bitnami https://charts.bitnami.com/bitnami

# List all repositories
helm repo list

# Update repository index
helm repo update

# Search for charts
helm search repo apache                   # Stable releases
helm search repo mysql --devel            # Include development versions
helm search repo --versions nginx         # Show all versions

# Remove a repository
helm repo remove bitnami
```

### **Bitnami Repository Specifics**
```bash
# Since August 2025, Bitnami requires subscription for latest images
# Free tier workaround:
helm install mydb bitnami/mysql --set image.repository=bitnamilegacy/mysql

# Warnings you'll see:
# 1. Limited free tier images available
# 2. Rolling tags (:latest) not recommended for production
# 3. Resources should be explicitly set
```

---

## **3. RELEASE LIFECYCLE**

### **Installation**

```bash
# Basic installation
helm install mysql wso2/mysql

# With custom name
helm install my-database bitnami/mysql

# Generate random name
helm install bitnami/apache --generate-name

# Custom naming template
helm install bitnami/apache --generate-name --name-template "web-{{randAlpha 5 | lower}}"
```

### **Upgrade & Rollback**

```bash
# Upgrade with new values
helm upgrade mysql wso2/mysql --set testFramework.enabled=false

# Upgrade with values file
helm upgrade mysql bitnami/mysql -f mysql-values.yaml

# Reuse previous values (dangerous - may use defaults for missing values)
helm upgrade mydb bitnami/mysql --reuse-values

# Force upgrade (deletes and recreates resources - causes downtime)
helm upgrade myapp bitnami/tomcat --force

# Check upgrade history
helm history mysql

# Rollback to specific revision
helm rollback mysql 1
```

### **Uninstallation**

```bash
# Complete removal
helm uninstall mysql

# Keep history (resources remain, only Helm metadata removed)
helm uninstall server --keep-history
```

### **Status & Inspection**

```bash
# List all releases
helm ls
helm list
helm list --all-namespaces

# Get release information
helm status mysql
helm get notes mysql                    # Show NOTES.txt
helm get values mysql                   # Show user-supplied values
helm get values mysql --all            # Show all values (including defaults)
helm get values mysql --revision 2     # Show values for specific revision

# Get manifest
helm get manifest mysql
```

---

## **4. CONFIGURATION MANAGEMENT**

### **Setting Values**

#### **Method 1: Command Line (--set)**
```bash
# Single value
helm install mysql bitnami/mysql --set auth.rootPassword=Secret123

# Nested values
helm install mysql bitnami/mysql \
  --set auth.rootPassword=Secret123 \
  --set auth.database=appdb \
  --set primary.persistence.size=10Gi

# Arrays/lists
helm install myapp bitnami/app --set "podAnnotations.key=value"
```

#### **Method 2: Values File (Recommended)**
```yaml
# mysql-values.yaml
auth:
  rootPassword: StrongRootPass123
  database: appdb
  username: appuser
  password: AppUserPass123

primary:
  persistence:
    enabled: true
    size: 10Gi
    storageClass: standard

  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: 500m
      memory: 1Gi

service:
  type: ClusterIP
```

```bash
# Install with values file
helm install mysql bitnami/mysql -f mysql-values.yaml

# Override values file with command line
helm install mysql bitnami/mysql -f mysql-values.yaml --set replicaCount=3
```

#### **Method 3: Multiple Values Files**
```bash
# Base values + environment-specific overrides
helm install myapp bitnami/app -f values.yaml -f production.yaml
```

### **Template Rendering & Validation**

```bash
# Dry run (see what would be deployed)
helm install server bitnami/tomcat --dry-run=client

# Render templates locally
helm template server bitnami/tomcat

# Debug template rendering
helm template server bitnami/tomcat --debug

# Lint chart (validate)
helm lint ./mychart
```

---

## **5. ADVANCED OPERATIONS**

### **Installation Options**

```bash
# Wait for resources to be ready
helm install myapp bitnami/nginx --wait
helm install myapp bitnami/nginx --wait --timeout 60s  # Custom timeout

# Atomic installation (auto-rollback on failure)
helm install myapp bitnami/nginx --atomic

# Create namespace if it doesn't exist
helm install myapp bitnami/nginx --namespace myns --create-namespace

# Skip CRDs
helm install myapp bitnami/app --skip-crds

# Wait for jobs to complete
helm install myapp bitnami/app --wait-for-jobs
```

### **Namespace Management**

```bash
# Set namespace context
kubectl config set-context --current --namespace tomcat

# Install in specific namespace
helm install tomcat bitnami/tomcat --namespace tomcat

# List releases across all namespaces
helm list --all-namespaces

# Get values from specific namespace
helm get values mysql --namespace production
```

### **Upgrade Strategies**

```bash
# Combined install/upgrade
helm upgrade --install myapp bitnami/nginx

# Three-way merge strategy (Helm 3)
helm upgrade myapp bitnami/nginx --three-way-merge

# Force resource update
helm upgrade myapp bitnami/nginx --force

# Reset values to defaults
helm upgrade myapp bitnami/nginx --reset-values
```

---

## **6. DEBUGGING & TROUBLESHOOTING**

### **Common Issues & Solutions**

#### **Issue 1: Image Pull Errors (Bitnami Free Tier)**
```bash
# Error: Image not available in free tier
# Solution: Use legacy images
helm install mysql bitnami/mysql --set image.repository=bitnamilegacy/mysql
```

#### **Issue 2: Readiness Probe Failures**
```bash
# Check pod status
kubectl describe pod <pod-name>

# Check logs
kubectl logs <pod-name>

# Common fix: Increase initial delay
helm upgrade app bitnami/app --set readinessProbe.initialDelaySeconds=60
```

#### **Issue 3: Persistent Volume Claims Pending**
```bash
# Check PVC status
kubectl get pvc

# Check storage class
kubectl get storageclass

# Fix: Specify storage class or reduce size
helm upgrade mysql bitnami/mysql --set primary.persistence.storageClass=standard
```

### **Diagnostic Commands**

```bash
# Check Kubernetes resources created by Helm
kubectl get all -l app.kubernetes.io/instance=mysql

# View Helm release secrets
kubectl get secrets | grep helm.release

# Decode secret values
kubectl get secret mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode

# Test database connection (example)
MYSQL_ROOT_PASSWORD=$(kubectl get secret mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
mysql -h 127.0.0.1 -P 3306 -u root -p$MYSQL_ROOT_PASSWORD
```

### **Port Forwarding for Testing**

```bash
# Forward service port locally
kubectl port-forward svc/mysql 3306:3306

# Connect to forwarded service
mysql -h 127.0.0.1 -P 3306 -u root -p$(kubectl get secret mysql -o jsonpath="{.data.mysql-root-password}" | base64 --decode)
```

---

## **7. BEST PRACTICES**

### **Configuration Management**
✅ **DO:**
- Use values files for production deployments
- Version control your values files
- Use separate values files per environment
- Set explicit resource limits

❌ **DON'T:**
- Use `:latest` tags in production
- Store secrets in values files (use Kubernetes Secrets)
- Use `--reuse-values` without understanding implications

### **Release Management**
```bash
# Good: Version-controlled values
helm upgrade myapp ./chart -f values/production.yaml

# Good: Atomic deployments
helm upgrade myapp ./chart --atomic --wait

# Good: Test before applying
helm upgrade myapp ./chart --dry-run

# Bad: Unreproducible
helm upgrade myapp ./chart --set key1=val1 --set key2=val2
```

### **Security Practices**
1. **Use Secrets for sensitive data**
   ```yaml
   # Instead of:
   password: PlainTextPassword
   
   # Use:
   existingSecret: mysql-secret
   secretKey: password
   ```

2. **Enable security contexts**
   ```bash
   helm install app bitnami/app --set securityContext.enabled=true
   ```

3. **Regular updates**
   ```bash
   # Check for updates
   helm search repo bitnami/mysql --versions
   
   # Update dependencies
   helm dependency update ./mychart
   ```

### **Performance Optimization**
```bash
# Set appropriate resource limits
helm install app bitnami/app \
  --set resources.requests.cpu=100m \
  --set resources.requests.memory=256Mi \
  --set resources.limits.cpu=500m \
  --set resources.limits.memory=512Mi

# Configure probes
helm install app bitnami/app \
  --set livenessProbe.initialDelaySeconds=30 \
  --set readinessProbe.initialDelaySeconds=5
```

---

## **8. REAL-WORLD EXAMPLES**

### **Complete MySQL Deployment**
```bash
# Step 1: Add repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Step 2: Create values file
cat > mysql-prod.yaml <<EOF
auth:
  rootPassword: "$(openssl rand -base64 16)"
  database: appdb
  username: appuser
  password: "$(openssl rand -base64 16)"

primary:
  persistence:
    enabled: true
    size: 20Gi
    storageClass: gp2
  resources:
    requests:
      cpu: 500m
      memory: 1Gi
    limits:
      cpu: 1
      memory: 2Gi

service:
  type: ClusterIP
  
metrics:
  enabled: true
EOF

# Step 3: Install
helm install mysql-prod bitnami/mysql \
  -f mysql-prod.yaml \
  --namespace database \
  --create-namespace \
  --wait \
  --timeout 5m

# Step 4: Verify
helm status mysql-prod --namespace database
kubectl get pods -n database
```

### **Tomcat with Custom Configuration**
```bash
# Create values file
cat > tomcat-custom.yaml <<EOF
image:
  repository: bitnamilegacy/tomcat
  tag: "11.0"

service:
  type: LoadBalancer
  port: 80
  
tomcat:
  username: admin
  password: "$(openssl rand -base64 12)"

persistence:
  enabled: true
  size: 10Gi

resources:
  requests:
    cpu: 200m
    memory: 512Mi
  limits:
    cpu: 500m
    memory: 1Gi

readinessProbe:
  initialDelaySeconds: 60
  periodSeconds: 10
  
livenessProbe:
  initialDelaySeconds: 120
  periodSeconds: 20
EOF

# Install
helm install tomcat-app bitnami/tomcat \
  -f tomcat-custom.yaml \
  --wait \
  --atomic
```

### **Application Stack (Multi-chart)**
```bash
# Deploy database
helm install postgresql bitnami/postgresql \
  --set auth.database=myapp \
  --set auth.username=myuser \
  --set primary.persistence.size=10Gi

# Deploy Redis cache
helm install redis bitnami/redis \
  --set architecture=standalone \
  --set master.persistence.size=5Gi

# Deploy application
helm install myapp ./myapp-chart \
  --set database.host=postgresql \
  --set redis.host=redis
```

---

## **QUICK REFERENCE CHEAT SHEET**

### **Essential Commands**
```bash
# Repository
helm repo add <name> <url>
helm repo update
helm search repo <term>

# Installation
helm install <name> <chart> [flags]
helm install <name> <chart> -f values.yaml
helm upgrade --install <name> <chart>

# Management
helm ls
helm status <release>
helm history <release>
helm rollback <release> <revision>
helm uninstall <release>

# Configuration
helm get values <release>
helm get manifest <release>
helm template <chart>
```

### **Common Flags**
```bash
--namespace <ns>           # Deploy to specific namespace
--create-namespace         # Create namespace if needed
--wait                     # Wait for resources ready
--timeout <duration>       # Wait timeout (e.g., 5m)
--atomic                   # Rollback on failure
--dry-run                  # Simulate installation
--debug                    # Enable debug output
--set key=value            # Set individual values
-f values.yaml            # Use values file
--values values.yaml      # Alias for -f
--version <version>       # Specific chart version
```

### **Troubleshooting Flow**
```
1. helm status <release>           # Check release status
2. kubectl get pods                # Check pod status
3. kubectl describe pod <pod>      # Get pod details
4. kubectl logs <pod>              # Check logs
5. helm get values <release>       # Check configuration
6. helm history <release>          # Check revision history
7. helm rollback <release> <rev>   # Rollback if needed
```

This comprehensive guide covers Helm from basic to advanced usage, with practical examples and best practices for production deployments.