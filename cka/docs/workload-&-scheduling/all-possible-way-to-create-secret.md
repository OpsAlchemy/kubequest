# Kubernetes Secrets - Complete Reference Guide

## 1. Secret Types Overview

### Built-in Secret Types
```bash
kubectl create secret --help
```
Shows three main types:
1. **docker-registry** - For accessing Docker registries
2. **generic** - For arbitrary key-value pairs (most common)
3. **tls** - For SSL/TLS certificates

## 2. Creating Generic Secrets

### Basic Syntax
```bash
kubectl create secret generic NAME [OPTIONS]
```

### 2.1 From Literal Values
```bash
# Single literal
kubectl create secret generic app-secret \
  --from-literal=username=admin

# Multiple literals
kubectl create secret generic app-secret \
  --from-literal=username=admin \
  --from-literal=password=supersecret123 \
  --from-literal=api-key=abcd1234efgh5678

# With type specification
kubectl create secret generic app-secret \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=admin \
  --from-literal=password=secret
```

### 2.2 From Files
```bash
# Single file (key defaults to filename)
kubectl create secret generic app-secret \
  --from-file=config.properties

# Single file with custom key name
kubectl create secret generic app-secret \
  --from-file=app-config=config.properties

# Multiple files
kubectl create secret generic app-secret \
  --from-file=ssl-cert=server.crt \
  --from-file=ssl-key=server.key \
  --from-file=config=app.conf

# From directory (each file becomes a key)
kubectl create secret generic app-secret \
  --from-file=./secrets/
```

### 2.3 From Environment Files
```bash
# From .env file (key=value format)
kubectl create secret generic app-secret \
  --from-env-file=config.env

# Multiple environment files
kubectl create secret generic app-secret \
  --from-env-file=database.env \
  --from-env-file=api.env
```

### 2.4 Mixed Sources
```bash
kubectl create secret generic app-secret \
  --from-file=config.yaml \
  --from-literal=debug=true \
  --from-literal=max_connections=100 \
  --from-env-file=environment.env
```

## 3. Creating Docker Registry Secrets

### Basic Docker Registry Secret
```bash
kubectl create secret docker-registry regcred \
  --docker-server=https://index.docker.io/v1/ \
  --docker-username=myuser \
  --docker-password=mypassword \
  --docker-email=myemail@example.com
```

### Using Existing Docker Config
```bash
kubectl create secret docker-registry regcred \
  --from-file=.dockerconfigjson=/root/.docker/config.json
```

### Short Form
```bash
kubectl create secret docker-registry regcred \
  --docker-username=myuser \
  --docker-password=mypassword
```

## 4. Creating TLS Secrets

### Basic TLS Secret
```bash
kubectl create secret tls app-tls \
  --cert=server.crt \
  --key=server.key
```

### With Custom CN and SANs
```bash
# First generate certs
openssl req -x509 -nodes -days 365 \
  -newkey rsa:2048 \
  -keyout tls.key \
  -out tls.crt \
  -subj "/CN=myapp.example.com"

# Then create secret
kubectl create secret tls app-tls \
  --cert=tls.crt \
  --key=tls.key
```

## 5. Advanced Creation Methods

### 5.1 With Hash Appended (Immutable)
```bash
kubectl create secret generic app-secret \
  --from-literal=token=xyz123 \
  --append-hash
# Creates: app-secret-57g7hfg8
```

### 5.2 Dry Run for Validation
```bash
# Client-side dry run
kubectl create secret generic app-secret \
  --from-literal=key=value \
  --dry-run=client \
  -o yaml

# Server-side dry run
kubectl create secret generic app-secret \
  --from-literal=key=value \
  --dry-run=server
```

### 5.3 Output Format Options
```bash
# YAML output
kubectl create secret generic app-secret \
  --from-literal=key=value \
  -o yaml

# JSON output
kubectl create secret generic app-secret \
  --from-literal=key=value \
  -o json

# Name only
kubectl create secret generic app-secret \
  --from-literal=key=value \
  -o name
```

## 6. Manual YAML Creation

### Basic Generic Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  username: YWRtaW4=        # admin
  password: c3VwZXJzZWNyZXQ= # supersecret
```

### Docker Registry Secret YAML
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: regcred
type: kubernetes.io/dockerconfigjson
data:
  .dockerconfigjson: eyJhdXRocyI6eyJodHRwczovL2luZGV4LmRvY2tlci5pby92MSI6eyJ1c2VybmFtZSI6Im15dXNlciIsInBhc3N3b3JkIjoibXlwYXNzd29yZCIsImVtYWlsIjoibXllbWFpbEBleGFtcGxlLmNvbSJ9fX0=
```

### TLS Secret YAML
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-tls
type: kubernetes.io/tls
data:
  tls.crt: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUVmekNDQTYrZ0F3SUJBZ0l...
  tls.key: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVB...
```

### Service Account Token Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: sa-token
  annotations:
    kubernetes.io/service-account.name: default
type: kubernetes.io/service-account-token
```

## 7. Encoding and Decoding

### Base64 Encoding for Manual Creation
```bash
# Encode values
echo -n "admin" | base64
# YWRtaW4=

echo -n "supersecret" | base64
# c3VwZXJzZWNyZXQ=

# Decode from secret
kubectl get secret app-secret -o jsonpath='{.data.username}' | base64 --decode
```

### Creating with Encoded Values
```bash
# Create with pre-encoded values
USERNAME=$(echo -n "admin" | base64)
PASSWORD=$(echo -n "secret" | base64)

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: encoded-secret
type: Opaque
data:
  username: $USERNAME
  password: $PASSWORD
EOF
```

## 8. Special Secret Types

### Basic Auth Secret
```bash
kubectl create secret generic basic-auth \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=admin \
  --from-literal=password=secret
```

### SSH Auth Secret
```bash
kubectl create secret generic ssh-key \
  --type=kubernetes.io/ssh-auth \
  --from-file=ssh-privatekey=~/.ssh/id_rsa
```

### Bootstrap Token Secret
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: bootstrap-token-abc123
  namespace: kube-system
type: bootstrap.kubernetes.io/token
stringData:
  description: "Bootstrap token for node joining"
  token-id: abc123
  token-secret: xyz789
  usage-bootstrap-authentication: "true"
  usage-bootstrap-signing: "true"
  auth-extra-groups: system:bootstrappers:kubeadm:default-node-token
```

## 9. Working with Existing Secrets

### Edit Existing Secret
```bash
kubectl edit secret app-secret
```

### Update Secret Values
```bash
# Add/update key
kubectl create secret generic app-secret \
  --from-literal=newkey=newvalue \
  --dry-run=client \
  -o yaml | kubectl apply -f -

# Patch secret
kubectl patch secret app-secret \
  -p '{"data":{"newkey":"'$(echo -n "newvalue" | base64)'"}}'
```

### Copy Secrets Between Namespaces
```bash
kubectl get secret app-secret -o yaml \
  | sed 's/namespace: default/namespace: production/' \
  | kubectl apply -f -
```

## 10. Practical Examples

### Example 1: Database Credentials
```bash
kubectl create secret generic database-secret \
  --from-literal=DB_HOST=postgresql.default.svc.cluster.local \
  --from-literal=DB_PORT=5432 \
  --from-literal=DB_NAME=mydb \
  --from-literal=DB_USER=appuser \
  --from-literal=DB_PASSWORD=$(openssl rand -base64 32)
```

### Example 2: API Keys
```bash
kubectl create secret generic api-secrets \
  --from-file=stripe-key=stripe-api.key \
  --from-file=aws-credentials=aws-keys.env \
  --from-literal=google-api-key=AIzaSyABCDEF123456789
```

### Example 3: Application Config
```bash
# Create config file
cat > app-config.properties <<EOF
server.port=8080
spring.datasource.url=jdbc:postgresql://localhost/mydb
logging.level.root=INFO
EOF

# Create secret
kubectl create secret generic app-config \
  --from-file=application.properties=app-config.properties
```

### Example 4: WordPress Deployment
```bash
# Generate random passwords
WORDPRESS_DB_PASSWORD=$(openssl rand -base64 32)
MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)

# Create secrets
kubectl create secret generic mysql-secret \
  --from-literal=mysql-root-password=$MYSQL_ROOT_PASSWORD \
  --from-literal=mysql-password=$WORDPRESS_DB_PASSWORD

kubectl create secret generic wordpress-secret \
  --from-literal=wordpress-db-password=$WORDPRESS_DB_PASSWORD
```

## 11. Validation and Verification

### Verify Secret Creation
```bash
# List secrets
kubectl get secrets

# Describe secret
kubectl describe secret app-secret

# Get secret details
kubectl get secret app-secret -o yaml

# Check specific key
kubectl get secret app-secret \
  -o jsonpath='{.data.username}' | base64 --decode
```

### Test Secret in Pod
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: test-secret
spec:
  containers:
  - name: test
    image: busybox
    command: ["sh", "-c", "sleep 3600"]
    env:
    - name: SECRET_USERNAME
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: username
  restartPolicy: Never
```

## 12. Security Best Practices

### 1. Use Appropriate Secret Types
```bash
# Instead of generic for auth
kubectl create secret generic basic-auth \
  --type=kubernetes.io/basic-auth \
  --from-literal=username=admin \
  --from-literal=password=secret
```

### 2. Enable Encryption at Rest
```yaml
apiVersion: apiserver.config.k8s.io/v1
kind: EncryptionConfiguration
resources:
  - resources:
    - secrets
    providers:
    - aescbc:
        keys:
        - name: key1
          secret: <base64-encoded-secret>
    - identity: {}
```

### 3. Use External Secret Managers (CSI)
```yaml
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-secrets
spec:
  provider: azure
  parameters:
    keyvaultName: my-keyvault
    objects: |
      array:
        - |
          objectName: db-password
          objectType: secret
```

### 4. Rotate Secrets Regularly
```bash
# Generate new password
NEW_PASSWORD=$(openssl rand -base64 32)

# Update secret
kubectl create secret generic app-secret \
  --from-literal=password=$NEW_PASSWORD \
  --dry-run=client -o yaml | kubectl apply -f -

# Restart pods to pick up new secret
kubectl rollout restart deployment/myapp
```

## 13. Common Troubleshooting

### Secret Not Mounting
```bash
# Check if secret exists
kubectl get secret my-secret

# Check pod events
kubectl describe pod my-pod

# Check volume mounts
kubectl exec my-pod -- ls /etc/secrets
```

### Permission Denied
```bash
# Check RBAC
kubectl auth can-i get secret my-secret

# Check ServiceAccount
kubectl describe pod my-pod | grep ServiceAccount
```

### Encoding Issues
```bash
# Verify base64 encoding
kubectl get secret my-secret -o jsonpath='{.data}' | jq .

# Test decoding
echo "YWRtaW4=" | base64 --decode
```

## 14. Quick Reference Commands

### Creation Commands
```bash
# Quick literal secret
kubectl create secret generic quick-secret --from-literal=key=value

# From file
kubectl create secret generic file-secret --from-file=myfile.txt

# Docker registry
kubectl create secret docker-registry regcred --docker-username=user --docker-password=pass

# TLS
kubectl create secret tls tls-secret --cert=cert.crt --key=key.key
```

### Inspection Commands
```bash
# List all secrets
kubectl get secrets --all-namespaces

# Decode secret value
kubectl get secret my-secret -o jsonpath='{.data.password}' | base64 -d

# Export secret
kubectl get secret my-secret -o yaml > secret-backup.yaml
```

### Management Commands
```bash
# Update secret
kubectl create secret generic updated-secret --from-literal=new=value -o yaml --dry-run=client | kubectl apply -f -

# Delete secret
kubectl delete secret old-secret

# Label secret
kubectl label secret my-secret environment=production
```

## Summary

1. **Generic secrets** are the most flexible for arbitrary data
2. **Docker registry secrets** are specialized for image pull authentication
3. **TLS secrets** are for SSL certificates
4. Always use `--from-literal` for small values and `--from-file` for files
5. Secrets are base64-encoded but not encrypted by default
6. Use appropriate secret types for better integration
7. Enable encryption at rest for production security
8. Consider external secret managers for enterprise deployments

Remember: Secrets are not encrypted by default in etcd. For production, always enable encryption at rest and consider using external secret management solutions.