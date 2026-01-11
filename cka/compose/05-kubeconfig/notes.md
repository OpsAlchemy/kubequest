# Kubeconfig & Kubernetes PKI Fundamentals

Comprehensive guide to understanding Kubernetes PKI (Public Key Infrastructure), X.509 certificates, and kubeconfig file structure. Learn how to work with certificates, create custom users, and manage cluster authentication.

## Quick Reference: kubectl config Commands

```bash
# View configuration
kubectl config view                    # Show entire kubeconfig
kubectl config view --raw              # Show with decoded credentials
kubectl config view --flatten          # Merge all kubeconfigs
kubectl config view --minify           # Show only current context
kubectl config view -o json            # Output as JSON

# Set cluster
kubectl config set-cluster kubernetes \
  --server=https://172.30.1.2:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt

# Set user credentials (certificate-based)
kubectl config set-credentials kubelet \
  --client-certificate=/etc/kubernetes/pki/kubelet.crt \
  --client-key=/etc/kubernetes/pki/kubelet.key \
  --embed-certs=true

# Set user credentials (token-based)
kubectl config set-credentials token-user \
  --token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...

# Create context
kubectl config set-context default \
  --cluster=kubernetes \
  --user=kubelet \
  --namespace=default

# Use context
kubectl config use-context default

# Get current context
kubectl config current-context

# Get all clusters, users, contexts
kubectl config get-clusters
kubectl config get-users
kubectl config get-contexts

# Rename context
kubectl config rename-context old-name new-name

# Delete entries
kubectl config delete-cluster cluster-name
kubectl config delete-user user-name
kubectl config delete-context context-name

# Unset (remove) configuration
kubectl config unset current-context
kubectl config unset clusters.cluster-name
kubectl config unset users.user-name
kubectl config unset contexts.context-name.namespace
```

---

## Advanced: kubectl config Usage Patterns

### Pattern 1: Setup Complete Cluster Access (One Command Sequence)

```bash
# 1. Add cluster configuration
kubectl config set-cluster prod-cluster \
  --server=https://api.prod.example.com:6443 \
  --certificate-authority=/path/to/ca.crt

# 2. Add user with certificate
kubectl config set-credentials prod-admin \
  --client-certificate=/path/to/admin.crt \
  --client-key=/path/to/admin.key \
  --embed-certs=true

# 3. Create context binding
kubectl config set-context prod-admin \
  --cluster=prod-cluster \
  --user=prod-admin \
  --namespace=default

# 4. Switch to use it
kubectl config use-context prod-admin

# Verify
kubectl cluster-info
kubectl get nodes
```

### Pattern 2: Add Token-Based User

```bash
# For service account tokens
kubectl config set-credentials service-user \
  --token=$(kubectl create token my-service-account)

# For predefined token
kubectl config set-credentials token-user \
  --token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0...

# Use in context
kubectl config set-context token-context \
  --cluster=kubernetes \
  --user=token-user
```

### Pattern 3: Multiple Kubeconfigs

```bash
# Combine multiple kubeconfig files
export KUBECONFIG=~/.kube/config:~/.kube/prod-config:~/.kube/dev-config

# View all merged
kubectl config view

# Switch between clusters easily
kubectl config use-context prod-admin
kubectl config use-context dev-admin

# Make permanent
echo 'export KUBECONFIG=~/.kube/config:~/.kube/prod-config:~/.kube/dev-config' >> ~/.zshrc
```

### Pattern 4: Extract User Credentials

```bash
# Extract certificate from kubeconfig
kubectl config view --raw | \
  grep 'client-certificate-data:' | \
  head -1 | \
  awk '{print $2}' | \
  base64 -d > user.crt

# Extract key from kubeconfig
kubectl config view --raw | \
  grep 'client-key-data:' | \
  head -1 | \
  awk '{print $2}' | \
  base64 -d > user.key

# Extract CA certificate
kubectl config view --raw | \
  grep 'certificate-authority-data:' | \
  head -1 | \
  awk '{print $2}' | \
  base64 -d > ca.crt
```

### Pattern 5: Context-Specific Namespace

```bash
# Create different contexts pointing to same cluster but different namespaces
kubectl config set-context dev-namespace \
  --cluster=kubernetes \
  --user=devuser \
  --namespace=development

kubectl config set-context prod-namespace \
  --cluster=kubernetes \
  --user=devuser \
  --namespace=production

# Switch context to change namespace automatically
kubectl config use-context dev-namespace   # Now using development namespace
kubectl get pods                            # Shows pods from development
kubectl config use-context prod-namespace  # Now using production namespace
kubectl get pods                            # Shows pods from production
```

### Pattern 6: Temporary Context Override

```bash
# Switch context just for one command
kubectl --context=staging-admin get nodes

# Override namespace for one command
kubectl --namespace=kube-system get pods

# Override entire cluster connection
kubectl --server=https://different-api:6443 get nodes
```

### Pattern 7: Audit Kubeconfig

```bash
# Show current context
kubectl config current-context

# Show all contexts with current marker
kubectl config get-contexts

# Show which cluster/user/namespace current context uses
kubectl config view | grep -A3 "current-context"

# Check if specific context exists
kubectl config get-contexts | grep "^[*]" | awk '{print $2}'

# Get API server for current context
kubectl config view | grep -A2 "current-context" | grep cluster | awk '{print $2}'
```

### Pattern 8: Cluster Switching Script

```bash
#!/bin/bash
# Interactive cluster switcher

# Get all contexts
CONTEXTS=$(kubectl config get-contexts | awk 'NR > 1 {print $2}')

echo "Available contexts:"
select CONTEXT in $CONTEXTS; do
  kubectl config use-context "$CONTEXT"
  echo "Switched to: $CONTEXT"
  kubectl config current-context
  kubectl cluster-info | head -1
  break
done
```

---

## Part 1: Kubernetes PKI Basics

### What is PKI?

**PKI (Public Key Infrastructure)** is a system for creating, managing, and validating digital certificates used for authentication and encryption in Kubernetes. Every component that needs to authenticate uses certificates signed by the cluster's Certificate Authority (CA).

### PKI Directory Structure

All Kubernetes certificates are stored in `/etc/kubernetes/pki/`:

```
/etc/kubernetes/pki/
├── ca.crt                  # Cluster CA certificate (what signed everything)
├── ca.key                  # Cluster CA private key (secret! signs new certs)
├── apiserver.crt           # API Server certificate
├── apiserver.key           # API Server private key
├── kubelet*.crt            # Kubelet certificates
├── controller-manager.crt  # Controller manager certificate
├── scheduler.crt           # Scheduler certificate
├── front-proxy-ca.*        # Front proxy CA for API aggregation
├── etcd/                   # ETCD certificates (database)
│   ├── ca.crt
│   ├── server.crt
│   └── server.key
└── sa.key                  # Service account signing key (not X.509)
```

### Why Multiple CAs?

Kubernetes uses different CAs for security isolation:

1. **Cluster CA** (`ca.crt/ca.key`): Main CA, signs kubelet, controller-manager, scheduler certificates
2. **API Server CA**: Dedicated CA for API server communication
3. **Front Proxy CA**: For aggregated API servers
4. **ETCD CA**: Isolated CA for ETCD database communication

---

## Part 2: Understanding X.509 Certificates

### Certificate Structure

Every X.509 certificate contains identity information:

```
Certificate Structure
├── Version: v3 (X.509v3)
├── Serial Number: Unique ID (2897472356293683110)
├── Signature Algorithm: sha256WithRSAEncryption
├── Issuer: CN=kubernetes (who signed this cert)
├── Validity Period
│   ├── Not Before: Jan 1 2026 GMT
│   └── Not After: Dec 30 2035 GMT (10 year validity)
├── Subject: CN=kubernetes-admin (who this cert is for)
├── Public Key Info
│   ├── Algorithm: RSA
│   └── Size: 2048 bits
└── Extensions (critical for Kubernetes)
    ├── Subject Alternative Names (SAN): DNS names, IP addresses
    ├── Key Usage: digitalSignature, keyEncipherment
    └── Extended Key Usage: serverAuth, clientAuth
```

### Certificate Components

#### 1. **CN (Common Name)** - The Identity

CN identifies WHO the certificate is for:

```
CN=kubernetes-admin      # User name "kubernetes-admin"
CN=kubelet              # System component "kubelet"
CN=controller-manager   # System component "controller-manager"
CN=kubernetes           # API server default identity
```

#### 2. **O (Organization)** - User Groups for RBAC

Organization field maps to groups, used for Role-Based Access Control:

```
O=system:masters              # Built-in admin group
O=kubeadm:cluster-admins      # Created by kubeadm (admins)
O=system:nodes                # For kubelet certificates
O=developers                  # Custom developer group
O=system:authenticated        # Standard authenticated users group
```

**Example Certificate Subject:**
```
Subject: O=kubeadm:cluster-admins, CN=kubernetes-admin
         ↓                      ↓
      Groups              User Name
```

#### 3. **SAN (Subject Alternative Names)** - Where the Certificate is Valid

SAN lists all valid hostnames and IPs for the certificate:

```
DNS Names:
- kubernetes
- kubernetes.default
- kubernetes.default.svc
- kubernetes.default.svc.cluster.local
- localhost

IP Addresses:
- 127.0.0.1 (localhost)
- 10.96.0.1 (Kubernetes service IP)
- 10.0.0.100 (Control plane node IP)
- 10.0.0.101 (Other control plane nodes)
```

**Why important?** If a DNS name or IP is NOT in SAN, the certificate is invalid for that endpoint!

---

## Part 3: Inspecting Certificates with OpenSSL

### Basic Certificate Inspection

```bash
# View certificate details
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout

# View first 30 lines
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout | head -30

# Extract specific fields
openssl x509 -in cert.crt -noout -subject      # Get CN and O
openssl x509 -in cert.crt -noout -issuer       # Who signed it
openssl x509 -in cert.crt -noout -dates        # Validity period
```

### Extract Certificate from Kubeconfig

Kubeconfig stores certificates as base64-encoded data. To decode:

```bash
# Extract CA certificate from kubeconfig
kubectl config view --raw | \
  grep 'certificate-authority-data:' | head -1 | \
  awk '{print $2}' | \
  base64 -d > ca.crt

# Inspect
openssl x509 -in ca.crt -text -noout | head -20
```

### Check Certificate Validity

```bash
# View Not Before and Not After dates
openssl x509 -in cert.crt -noout -dates
# Output:
# notBefore=Jan  1 07:08:58 2026 GMT
# notAfter=Dec 30 07:13:58 2035 GMT

# Check days until expiration
openssl x509 -in cert.crt -noout -enddate | cut -d'=' -f2 | \
  xargs -I {} date -d {} +%s | \
  xargs -I {} expr \( {} - $(date +%s) \) / 86400
```

### View SAN Extensions

```bash
# See all Subject Alternative Names
openssl x509 -in cert.crt -text -noout | grep -A5 "Subject Alternative Name"

# Example output:
#     X509v3 Subject Alternative Name: 
#         DNS:kubernetes, DNS:kubernetes.default, DNS:kubernetes.default.svc, 
#         IP Address:10.96.0.1, IP Address:10.0.0.1
```

---

## Part 4: Kubeconfig File Format

### Complete Kubeconfig Structure

```yaml
apiVersion: v1
kind: Config
preferences: {}

# SECTION 1: Clusters - How to connect to clusters
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTi... # Base64 CA cert
    server: https://172.30.1.2:6443               # API server URL
  name: kubernetes                                 # Cluster name (identifier)

# SECTION 2: Users - Authentication credentials
users:
- name: kubernetes-admin
  user:
    # Method A: Certificate-based auth (most common)
    client-certificate-data: LS0tLS1CRUdJTi...    # Base64 client cert
    client-key-data: LS0tLS1CRUdJTi...            # Base64 client key
    
# SECTION 3: Contexts - Bind (cluster + user + namespace)
contexts:
- context:
    cluster: kubernetes           # Which cluster (from clusters[])
    user: kubernetes-admin        # Which user (from users[])
    namespace: default            # Default namespace for this context
  name: kubernetes-admin@kubernetes  # Context name (identifier)

# SECTION 4: Current context - Default when you run kubectl
current-context: kubernetes-admin@kubernetes
```

### Section Details

#### **Clusters Section**

Defines how to reach a Kubernetes cluster:

```yaml
clusters:
- cluster:
    # CA cert to verify API server certificate
    certificate-authority-data: [base64 encoded]
    # OR use file path:
    # certificate-authority: /etc/kubernetes/pki/ca.crt
    
    # API server URL
    server: https://api.example.com:6443
    
    # DANGEROUS: Skip cert verification (never in production)
    # insecure-skip-tls-verify: true
  name: production-cluster
```

#### **Users Section**

Defines HOW to authenticate:

```yaml
users:
- name: admin
  user:
    # Method 1: Certificate + Key (TLS client auth)
    client-certificate-data: [base64]
    client-key-data: [base64]
    
    # Method 2: Token (for service accounts)
    token: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
    
    # Method 3: Username/Password (deprecated, rarely used)
    username: user
    password: pass123
```

#### **Contexts Section**

Binds together cluster + user + namespace:

```yaml
contexts:
- context:
    cluster: production-cluster   # Reference from clusters[]
    user: admin                   # Reference from users[]
    namespace: kube-system        # Default namespace for commands
  name: prod-admin               # Context identifier
```

---

## Part 5: Creating Custom Users with Certificates

### Step 1: Generate Private Key

```bash
# Create a 2048-bit RSA private key for the user
openssl genrsa -out devuser.key 2048

# Result: A private key file that should be kept secret
```

### Step 2: Create Certificate Signing Request (CSR)

A CSR is a request to the CA to sign a certificate:

```bash
openssl req -new \
  -key devuser.key \
  -out devuser.csr \
  -subj "/CN=devuser/O=developers/O=kubeadm:cluster-admins"

# /CN=devuser              → Username (Common Name)
# /O=developers            → Group 1
# /O=kubeadm:cluster-admins → Group 2 (RBAC admin group)
```

### Step 3: Sign CSR with Cluster CA

The cluster admin signs the CSR, creating a valid certificate:

```bash
# Sign CSR with cluster CA (valid for 365 days)
openssl x509 -req -in devuser.csr \
  -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key \
  -CAcreateserial \
  -out devuser.crt \
  -days 365

# After this, devuser.crt is a valid Kubernetes certificate
```

### Step 4: Add to Kubeconfig

```bash
# 1. Add cluster (if not already there)
kubectl config set-cluster kubernetes \
  --server=https://api.example.com:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt

# 2. Add user with certificate
kubectl config set-credentials devuser \
  --client-certificate=devuser.crt \
  --client-key=devuser.key \
  --embed-certs=true    # Embed cert/key data in kubeconfig file

# 3. Create context
kubectl config set-context devuser-context \
  --cluster=kubernetes \
  --user=devuser

# 4. Switch to use this context
kubectl config use-context devuser-context

# 5. Verify connection
kubectl get nodes
```

### Complete Automation Script

```bash
#!/bin/bash
set -e

USERNAME="devuser"
GROUP="developers"
DAYS_VALID=365
CLUSTER_IP="api.example.com:6443"
CA_CERT="/etc/kubernetes/pki/ca.crt"
CA_KEY="/etc/kubernetes/pki/ca.key"

echo "[1/5] Generating private key..."
openssl genrsa -out ${USERNAME}.key 2048

echo "[2/5] Creating certificate signing request..."
openssl req -new \
  -key ${USERNAME}.key \
  -out ${USERNAME}.csr \
  -subj "/CN=${USERNAME}/O=${GROUP}"

echo "[3/5] Signing CSR with cluster CA..."
openssl x509 -req -in ${USERNAME}.csr \
  -CA ${CA_CERT} \
  -CAkey ${CA_KEY} \
  -CAcreateserial \
  -out ${USERNAME}.crt \
  -days ${DAYS_VALID}

echo "[4/5] Adding to kubeconfig..."
kubectl config set-cluster kubernetes \
  --server=https://${CLUSTER_IP} \
  --certificate-authority=${CA_CERT}

kubectl config set-credentials ${USERNAME} \
  --client-certificate=${USERNAME}.crt \
  --client-key=${USERNAME}.key \
  --embed-certs=true

kubectl config set-context ${USERNAME}-context \
  --cluster=kubernetes \
  --user=${USERNAME}

echo "[5/5] Verifying..."
kubectl config get-contexts | grep ${USERNAME}

echo "✅ User '${USERNAME}' created successfully!"
echo "To use: kubectl config use-context ${USERNAME}-context"
echo "To apply RBAC: kubectl create rolebinding dev-role --clusterrole=view --user=${USERNAME}"
```

---

## Part 7: Kubernetes API CertificateSigningRequest (CSR)

### Creating CSR Through Kubernetes API (Real-World Method)

In production clusters, instead of manually signing certificates, you create a **CertificateSigningRequest** object and let the cluster's control plane sign it.

### Practical: Generate CSR and Submit to Kubernetes

#### Step 1: Generate Private Key and CSR (Client-Side)

```bash
# Generate private key
openssl genrsa -out newuser.key 2048

# Create CSR (note: generate CSR with subject, no signing yet)
openssl req -new \
  -key newuser.key \
  -out newuser.csr \
  -subj "/CN=newuser/O=developers"

# Verify CSR was created
openssl req -in newuser.csr -text -noout
```

#### Step 2: Create Kubernetes CSR Object

```bash
# Base64 encode the CSR
CSR_CONTENT=$(cat newuser.csr | base64 | tr -d '\n')

# Create CSR object
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: newuser-csr
spec:
  request: $CSR_CONTENT
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000  # 1 year
  usages:
  - client auth
EOF

# Verify CSR was created
kubectl get csr
kubectl describe csr newuser-csr
```

#### Step 3: Approve the CSR

```bash
# Admin approves the request
kubectl certificate approve newuser-csr

# Verify it's approved
kubectl get csr newuser-csr
# Status should show: Approved, Issued

# View the approved certificate (base64 encoded)
kubectl get csr newuser-csr -o jsonpath='{.status.certificate}' | base64 -d > newuser.crt

# Verify the certificate
openssl x509 -in newuser.crt -text -noout | head -20
```

#### Step 4: Add User to Kubeconfig

```bash
# Set cluster (if not already present)
kubectl config set-cluster kubernetes \
  --server=https://api.example.com:6443 \
  --certificate-authority=/path/to/ca.crt

# Add user with the issued certificate
kubectl config set-credentials newuser \
  --client-certificate=newuser.crt \
  --client-key=newuser.key \
  --embed-certs=true

# Create context
kubectl config set-context newuser-context \
  --cluster=kubernetes \
  --user=newuser

# Test access
kubectl config use-context newuser-context
kubectl get pods
```

### Complete Automation Script

```bash
#!/bin/bash
set -e

USERNAME="$1"
GROUP="${2:-developers}"
CLUSTER_NAME="${3:-kubernetes}"
API_SERVER="${4:-https://api.example.com:6443}"
CA_PATH="${5:-/etc/kubernetes/pki/ca.crt}"

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <username> [group] [cluster-name] [api-server] [ca-path]"
  exit 1
fi

echo "📋 Creating user certificate via Kubernetes CSR API..."
echo ""

# Step 1: Generate private key
echo "[1/5] Generating private key..."
openssl genrsa -out "${USERNAME}.key" 2048 2>/dev/null
chmod 600 "${USERNAME}.key"

# Step 2: Create CSR file
echo "[2/5] Creating certificate signing request..."
openssl req -new \
  -key "${USERNAME}.key" \
  -out "${USERNAME}.csr" \
  -subj "/CN=${USERNAME}/O=${GROUP}" 2>/dev/null

# Step 3: Submit CSR to Kubernetes
echo "[3/5] Submitting CSR to Kubernetes API..."
CSR_CONTENT=$(cat "${USERNAME}.csr" | base64 | tr -d '\n')

kubectl apply -f - <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${USERNAME}-csr
spec:
  request: $CSR_CONTENT
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

# Step 4: Wait for approval (manual or automated)
echo "[4/5] CSR created. Waiting for approval..."
echo "      Admin needs to run: kubectl certificate approve ${USERNAME}-csr"

# Optional: auto-approve for testing
# kubectl certificate approve ${USERNAME}-csr

# Wait for approval (with timeout)
TIMEOUT=300
ELAPSED=0
while [ $ELAPSED -lt $TIMEOUT ]; do
  STATUS=$(kubectl get csr "${USERNAME}-csr" -o jsonpath='{.status.conditions[?(@.type=="Approved")].type}' 2>/dev/null || echo "")
  if [ "$STATUS" == "Approved" ]; then
    echo "      ✅ CSR Approved!"
    break
  fi
  sleep 5
  ELAPSED=$((ELAPSED + 5))
done

# Step 5: Extract certificate and configure kubeconfig
echo "[5/5] Extracting certificate and configuring kubeconfig..."
kubectl get csr "${USERNAME}-csr" -o jsonpath='{.status.certificate}' | base64 -d > "${USERNAME}.crt"

# Configure kubeconfig
kubectl config set-cluster "${CLUSTER_NAME}" \
  --server="${API_SERVER}" \
  --certificate-authority="${CA_PATH}"

kubectl config set-credentials "${USERNAME}" \
  --client-certificate="${USERNAME}.crt" \
  --client-key="${USERNAME}.key" \
  --embed-certs=true

kubectl config set-context "${USERNAME}-context" \
  --cluster="${CLUSTER_NAME}" \
  --user="${USERNAME}"

echo ""
echo "✅ User '${USERNAME}' created successfully!"
echo ""
echo "📌 Files created:"
echo "   - ${USERNAME}.key      (private key - KEEP SECURE)"
echo "   - ${USERNAME}.csr      (certificate signing request)"
echo "   - ${USERNAME}.crt      (signed certificate)"
echo ""
echo "📌 To use this user:"
echo "   kubectl config use-context ${USERNAME}-context"
echo "   kubectl get pods"
echo ""
echo "📌 To grant permissions:"
echo "   kubectl create rolebinding ${USERNAME}-view --clusterrole=view --user=${USERNAME}"
```

### View and Manage CSRs

```bash
# List all CSRs
kubectl get csr

# Show detailed CSR info
kubectl describe csr <csr-name>

# Show CSR in YAML
kubectl get csr <csr-name> -o yaml

# View the original CSR content
kubectl get csr <csr-name> -o jsonpath='{.spec.request}' | base64 -d | openssl req -text -noout

# Approve CSR
kubectl certificate approve <csr-name>

# Deny CSR
kubectl certificate deny <csr-name>

# Delete CSR
kubectl delete csr <csr-name>

# Watch for pending CSRs
kubectl get csr --watch
```

### Available Signer Names

```bash
# Different signerName values for different certificate types:

# 1. Client certificate for connecting to API server
signerName: kubernetes.io/kube-apiserver-client

# 2. Kubelet serving certificate (for kubelet HTTPS endpoint)
signerName: kubernetes.io/kubelet-serving

# 3. Legacy (kubeadm) client certificate
signerName: kubernetes.io/kube-apiserver-client-kubelet

# Check available signers in your cluster:
kubectl get certificatesigningrequests.certificates.k8s.io -o json | \
  jq '.items[].spec.signerName' | sort | uniq
```

### CSR Best Practices for Kind Clusters

```bash
# 1. For kind, approve CSRs immediately or auto-approve them
kubectl certificate approve <csr-name>

# 2. Create a helper function for approval in testing
auto-approve-csrs() {
  kubectl get csr --no-headers | awk '{print $1}' | while read csr; do
    if kubectl get csr "$csr" -o jsonpath='{.status.conditions}' | grep -q Approved; then
      continue
    fi
    echo "Approving: $csr"
    kubectl certificate approve "$csr"
  done
}

# 3. Watch for pending CSRs
watch 'kubectl get csr'
```

---

## Part 8: Working with Kubeconfig - Examples

### Example 1: Create Read-Only Viewer Account

```bash
# Generate keys
openssl genrsa -out viewer.key 2048
openssl req -new -key viewer.key -out viewer.csr -subj "/CN=viewer/O=viewers"
openssl x509 -req -in viewer.csr -CA /etc/kubernetes/pki/ca.crt \
  -CAkey /etc/kubernetes/pki/ca.key -out viewer.crt -days 365

# Add to kubeconfig
kubectl config set-credentials viewer \
  --client-certificate=viewer.crt --client-key=viewer.key
kubectl config set-context viewer-context --cluster=kubernetes --user=viewer

# Create RBAC role binding
kubectl create rolebinding viewer-role --clusterrole=view --user=viewer
```

### Example 2: Certificate Expiration Check

```bash
# Check when certs expire
for cert in /etc/kubernetes/pki/*.crt; do
  echo "$cert:"
  openssl x509 -in "$cert" -noout -dates
done

# List certs expiring within 30 days
# (Useful for monitoring and renewal planning)
```

### Example 3: Verify Certificate Trust Chain

```bash
# Check if cert was signed by CA
openssl verify -CAfile /etc/kubernetes/pki/ca.crt cert.crt

# Output: cert.crt: OK (if valid)
```

---

**Last Updated:** January 9, 2026


~/.kube                                                                                                                      14:23:22
❯ kind get cluster
Gets one of [clusters, nodes, kubeconfig]

Usage:
  kind get [flags]
  kind get [command]

Available Commands:
  clusters    Lists existing kind clusters by their name
  kubeconfig  Prints cluster kubeconfig
  nodes       Lists existing kind nodes by their name

Flags:
  -h, --help   help for get

Global Flags:
  -q, --quiet             silence all stderr output
  -v, --verbosity int32   info log verbosity, higher value produces more output

Use "kind get [command] --help" for more information about a command.
ERROR: Subcommand is required

~/.kube                                                                                                                      14:24:45
❯ kind get clusters
gatewayapi

~/.kube                                                                                                                      14:24:53
❯ # Get kubeconfig for gatewayapi cluster
kind get kubeconfig --name=gatewayapi > /tmp/gatewayapi-kubeconfig.yaml

# Show the structure
cat /tmp/gatewayapi-kubeconfig.yaml
zsh: command not found: #
zsh: command not found: #
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURCVENDQWUyZ0F3SUJBZ0lJS0RYandhOW1KNll3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1ERXdOekE0TlRoYUZ3MHpOVEV5TXpBd056RXpOVGhhTUJVeApFekFSQmdOVkJBTVRDbXQxWW1WeWJtVjBaWE13Z2dFaU1BMEdDU3FHU0liM0RRRUJBUVVBQTRJQkR3QXdnZ0VLCkFvSUJBUUM1OHpsZnJGRUJRZHZuRzJ6MzBvQ09zODJnTldnUlNsWW5ZNGgwUkVtSE5DOVVYWmFNUm1hVHFCQ1kKT2pDbW9nMVhaYlFQcTE5MHFGTkV1ZDk2MDRjS3FhTFhHbGhuR20wZEQ1dWFtN3NsQngrQURmMzErbEhXYTNsSgpGU3A1WFlIMGxpb3dWMHpQVmN5RlpDZjk0UTIxejVMS1lvRmdXWHdTMG5oZUZ5WWZPdjFXWUV3cVExZVFlS0RGCjljbFNiQ0VpbEtUbDgzZng1MXZ1YThLcGExTmt3TG1tdzFBSHZkZXRBUnZBUDk2Zm5zTm94SFY0YVM3YVNTM1kKQkJUeC9SWExPaFVJRXFjbFZSSzNyeEF4T2NUYnVqaCtZRzh3Nmwrc3VBY296QmtNZmNzcGY4UjdxMm4wTkdkcAp4eGYvZG9WeUQxK200N3dKVzIyTDcxalN6OXNUQWdNQkFBR2pXVEJYTUE0R0ExVWREd0VCL3dRRUF3SUNwREFQCkJnTlZIUk1CQWY4RUJUQURBUUgvTUIwR0ExVWREZ1FXQkJTRXByTko1dmVOQU1kb1BWUlJ4cjJvUUpqUytqQVYKQmdOVkhSRUVEakFNZ2dwcmRXSmxjbTVsZEdWek1BMEdDU3FHU0liM0RRRUJDd1VBQTRJQkFRQmM5RnpOSEhTaAoyZnhJZ0l0azZEUVZRc3BpN0ZZcURKd3pKdFczZmx6ZHBnckF0STM4VTdmc0NhcnpFaFpQVmY3ODR2OTdFWHBDCmZabHRGVXlXL2xvWVlDZ1hnSGo1Sjh6MjNQSGxVVklJOUU0c1BYM1dKWlBjWmtsSWpyNFdDOFY1dzNpSms2aHoKZS9xdDhpb291QkFGNVlHM24ycTlSSUFuN0h3N3M0UCs5ZXJMOGlKbC80T0VOQWpNemRYMzJvZmJUenNzQlcyVwppelU4YWpVVnE0RkVRZW9zT3JmcWQvNURwcEJqb3lpZlJ1SXNLaDJNdG1vcFBtV3VLcTVLemI3M3BNcTJSeE5OClVWRDdXZWFzdTAxWVQrdEZTMlRqTFZyNGZxL1dYRjhDM0JUUHltZ3lUQWVxcXk4SzhVQlVFTnVBMG1FS1VONEcKcnVqbFZ1dEM1M0VXCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    server: https://127.0.0.1:39619
  name: kind-gatewayapi
contexts:
- context:
    cluster: kind-gatewayapi
    user: kind-gatewayapi
  name: kind-gatewayapi
current-context: kind-gatewayapi
kind: Config
users:
- name: kind-gatewayapi
  user:
    client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSURLVENDQWhHZ0F3SUJBZ0lJTGh0ajRISmR5Nkl3RFFZSktvWklodmNOQVFFTEJRQXdGVEVUTUJFR0ExVUUKQXhNS2EzVmlaWEp1WlhSbGN6QWVGdzB5TmpBeE1ERXdOekE0TlRoYUZ3MHlOekF4TURFd056RXpOVGhhTUR3eApIekFkQmdOVkJBb1RGbXQxWW1WaFpHMDZZMngxYzNSbGNpMWhaRzFwYm5NeEdUQVhCZ05WQkFNVEVHdDFZbVZ5CmJtVjBaWE10WVdSdGFXNHdnZ0VpTUEwR0NTcUdTSWIzRFFFQkFRVUFBNElCRHdBd2dnRUtBb0lCQVFDcWtwcEMKbndWQnNmMjFId2dGQ1Rod0dQR2RpcUtSVk42RVF3Z0Z3WnkzWjlNb0llRWZNa1MvYjlQOGxEY0d2Vk0vR3d3Rwp5RG4rcFJMK3ZYT2JObVNnblMveHNRK3NVamZnTERLb2V3ZHFBYXJCUG0vaHIxTXpPSXErdUdvMWRBeHZpcHNvCjNPQjc0Y0VsQmIxd2pxb3U1akwxRzNjNW9pbnRUSmFjcjJPcjZ3Z2JSaUsxaEF0ZjlPL2tFbndNRkQvdnV2NmMKSXZwVVB0aUtwUUJGZnhLRWdQYjZYOVZhc2J5d1Jab3JsS2pvSWlpVTNZM3ZBQ1FqSlExYVlEUm1JYW12bVNURQoyKzl4RDUweGY5MDNRSnp5UG45Umx0RzhPYnlHRTkvVW5IL1g2VER3UGRydFpwMjlXWHAxZDIrd3VyMld4a01PCnREZDZUbGNuV01kMStKL3JBZ01CQUFHalZqQlVNQTRHQTFVZER3RUIvd1FFQXdJRm9EQVRCZ05WSFNVRUREQUsKQmdnckJnRUZCUWNEQWpBTUJnTlZIUk1CQWY4RUFqQUFNQjhHQTFVZEl3UVlNQmFBRklTbXMwbm05NDBBeDJnOQpWRkhHdmFoQW1OTDZNQTBHQ1NxR1NJYjNEUUVCQ3dVQUE0SUJBUUJlUXk2N3YvMVdFUVB5bXV6L2V4NHlNdHgwCjY3S3BWQzkxUVZ1aEFjNUpZMWwwSnp3bWxjRzJrUk1lK2VFM3Erd1pEMTRmYVhKcjdrbGFjQkcxMXRsZUZKRXoKelZCVVArU3Jpbk9yN05wS3VlMGdmZ2FzTTJ4UkFRVWkyOXQvem5FTjZ3a1BzRzkvbUFBSGZZWTAzVjlxSmovMwp2N3NFcElrR3lxNzMzek5qRC81bHEvTFgvUWppeHc4MzE1b0h1WHMzekhmM3pONGkrZFhRQnAxTlk0TGVCQzFYCnVUa3lhbXJRR3ZQRTBsT2llTUlLQ3pkQ1k0cXlpb04yL2Jqd21KZStXYTBpNEorQ3VKQ0MyWjVKYVJpVUM1QUQKdW94Z1lYSXFSazlkekZ2SkU2WnRvWG9VMDVlS0oyNHFBaEd4UEViV2ptMDZJVEtwc3J3MCs0aUVLY09mCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
    client-key-data: LS0tLS1CRUdJTiBSU0EgUFJJVkFURSBLRVktLS0tLQpNSUlFcEFJQkFBS0NBUUVBcXBLYVFwOEZRYkg5dFI4SUJRazRjQmp4bllxaWtWVGVoRU1JQmNHY3QyZlRLQ0hoCkh6SkV2Mi9UL0pRM0JyMVRQeHNNQnNnNS9xVVMvcjF6bXpaa29KMHY4YkVQckZJMzRDd3lxSHNIYWdHcXdUNXYKNGE5VE16aUt2cmhxTlhRTWI0cWJLTnpnZStIQkpRVzljSTZxTHVZeTlSdDNPYUlwN1V5V25LOWpxK3NJRzBZaQp0WVFMWC9UdjVCSjhEQlEvNzdyK25DTDZWRDdZaXFVQVJYOFNoSUQyK2wvVldyRzhzRVdhSzVTbzZDSW9sTjJOCjd3QWtJeVVOV21BMFppR3ByNWtreE52dmNRK2RNWC9kTjBDYzhqNS9VWmJSdkRtOGhoUGYxSngvMStrdzhEM2EKN1dhZHZWbDZkWGR2c0xxOWxzWkREclEzZWs1WEoxakhkZmlmNndJREFRQUJBb0lCQUJJcUpPY0ZycFoxbG4rVQpkajJzWXQxcExVaC9nWVY1ajIxd0FxbUk3MHF4Y2Z3Rm5rYm5ZRjZFcHdOd1kwQnRVVndETjRUU0MzOEhPWjUxCmlCdFdMN2JTVm5ubUhHQlhySFNoTUU4MGlZWEJUTEVNbUV5UDU3WitNSG1wV096U3JCcGF4K0E4K1dPbjdISW8KQ2ltemxRTUQ1OEdtSGFHK2JRN3Zjalh0dXU4TlNXWFJRKzhtMHVYN2k1dGRUa3BXUkNKdEVYZzY5bmtLazF4LwpscHVHNS9RT2J3cDdrSVBYS0tuZTdYL1hRTnB6TCtSaHh3UVFxVllDUzhUMzZMVkVnMVZIbGV6OEpSQlVGNENvClRDUUM4SWgvVWY0TTBTWHd2Z1RJRXAyQlNWVThESWQzUHFhdk1RU2E2UmxZcnFmUHNFcXgwZ0tLSFhGM2ZjTDcKSXZadVFNRUNnWUVBM0cvQ21qZlJBY0lCVGJwYklYcXo2MEpjVEpZdDVDaEF3cEtYVjN5T3NmNGxDNG15MG1hcApNT2t5MWxkVXRMWnBaWTN2ejVqSE5rOUYyY3BiRjhRbHNyb3dPUzFjZ05XM1JVVExBaWZHRGpmak9uOTFiNHk2CjZ3T1hZSFlyRWszVXVrcm1tcTlRNlI1ek10bTNlNlNlRmlQSmovTzQzVUx1R2Z3MXNyanVmS3NDZ1lFQXhoZHEKZ0d5Z2wyellOSTc3ZWVmOVJRNTB2UGUwRFBKUGZWLzlXMldZWG1rMVQwNWVscWhEWXowRnhEWGo4aG9pZG5kTQpzZW42UUdueUdaMFQ3S0Uwc1pLWjlmaEZWWlhrYnM5dncxS3BsSlpCaG9uek1nVkVqeEw4ZGlwVVpTQmpuZHRjCmZmS3YvcncxdnpJdzZ0RDJ6Vk4vc21iQTFkT3hWTlFaQTZZZjZjRUNnWUVBZ0tBUi9HenZYMGcxL0lYdUlSWDUKSUNDanZPaXd0SDRzYzV5WUJLdWdsQW5JMGZleVNZVXYybU5vajV0N3lNcmJxeTlzTEVWb2tLOG5BaE5Lbmc2TgpOTUhoMjZzMVc5UFkwZWwzVDdXbm9xcEh3OTJWeDlabFJ6YmNRS1FUTStZSVovL0dtYUlNNDBvcVRCU3dOTXgwCmxsU2hpNGJhYXZsZjkvZXIyYktCTG1zQ2dZRUFsSWJzS1B6SjhLQUJBRytRNlJma0ZBcEJ4NHBtNnlvb0pkWjYKVGpRLzZkSXkwWkx1WTBJb3ZOajlZT0FUV096MW1DUGRVcTBnSVhvT3Q5dktHNnZIcWJsRlRXTnBBVUlSZEhCKwoyVkk2cXBsNjZoaTNTM01kczdWRnJJZ1NuWHlLbE1yc2I5Y3UxTzVqMGtjYzNJUHYrWVk1QWhmL1VKU1lxd1VZCitGNXdJVUVDZ1lCdE9FNGhzQXJteDgrbFRHQUJKMHRSdjZkYzE5WFJlUFFYY2NUV3gyQWt1alM5b1dmSHduUmIKWHVZQkI3Yi9TV05jcVJiNTZjMTZRZWYrZzFPb1RObGpaeHZmblg2WUZoUnNOeXNYeUtxUnRZdHZUcXhUM2VjbQpYdTlKWXVpUmx1enBJSUc5S1QrVS95VU1qcjFVa0x3Nmw5dU9mcGtSVko1elF2VVFSeXdvcXc9PQotLS0tLUVORCBSU0EgUFJJVkFURSBLRVktLS0tLQo=


~/.kube                                                                                                                      14:25:21
❯ sed -n '/certificate-authority-data:/,/^[[:space:]]*server:/p' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'certificate-authority-data:' | \
  cut -d':' -f2- | \
  tr -d ' ' | \
  base64 -d > /tmp/decoded-ca.crt

~/.kube                                                                                                                      14:28:18
❯ cat /tmp/decoded-ca.crt
-----BEGIN CERTIFICATE-----
MIIDBTCCAe2gAwIBAgIIKDXjwa9mJ6YwDQYJKoZIhvcNAQELBQAwFTETMBEGA1UE
AxMKa3ViZXJuZXRlczAeFw0yNjAxMDEwNzA4NThaFw0zNTEyMzAwNzEzNThaMBUx
EzARBgNVBAMTCmt1YmVybmV0ZXMwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
AoIBAQC58zlfrFEBQdvnG2z30oCOs82gNWgRSlYnY4h0REmHNC9UXZaMRmaTqBCY
OjCmog1XZbQPq190qFNEud9604cKqaLXGlhnGm0dD5uam7slBx+ADf31+lHWa3lJ
FSp5XYH0liowV0zPVcyFZCf94Q21z5LKYoFgWXwS0nheFyYfOv1WYEwqQ1eQeKDF
9clSbCEilKTl83fx51vua8Kpa1NkwLmmw1AHvdetARvAP96fnsNoxHV4aS7aSS3Y
BBTx/RXLOhUIEqclVRK3rxAxOcTbujh+YG8w6l+suAcozBkMfcspf8R7q2n0NGdp
xxf/doVyD1+m47wJW22L71jSz9sTAgMBAAGjWTBXMA4GA1UdDwEB/wQEAwICpDAP
BgNVHRMBAf8EBTADAQH/MB0GA1UdDgQWBBSEprNJ5veNAMdoPVRRxr2oQJjS+jAV
BgNVHREEDjAMggprdWJlcm5ldGVzMA0GCSqGSIb3DQEBCwUAA4IBAQBc9FzNHHSh
2fxIgItk6DQVQspi7FYqDJwzJtW3flzdpgrAtI38U7fsCarzEhZPVf784v97EXpC
fZltFUyW/loYYCgXgHj5J8z23PHlUVII9E4sPX3WJZPcZklIjr4WC8V5w3iJk6hz
e/qt8ioouBAF5YG3n2q9RIAn7Hw7s4P+9erL8iJl/4OENAjMzdX32ofbTzssBW2W
izU8ajUVq4FEQeosOrfqd/5DppBjoyifRuIsKh2MtmopPmWuKq5Kzb73pMq2RxNN
UVD7Weasu01YT+tFS2TjLVr4fq/WXF8C3BTPymgyTAeqqy8K8UBUENuA0mEKUN4G
rujlVutC53EW
-----END CERTIFICATE-----

~/.kube                                                                                                                      14:28:22
❯ openssl x509 -in /tmp/decoded-ca.crt -text -noout | head -30
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 2897472356293683110 (0x2835e3c1af6627a6)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: Jan  1 07:08:58 2026 GMT
            Not After : Dec 30 07:13:58 2035 GMT
        Subject: CN = kubernetes
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:b9:f3:39:5f:ac:51:01:41:db:e7:1b:6c:f7:d2:
                    80:8e:b3:cd:a0:35:68:11:4a:56:27:63:88:74:44:
                    49:87:34:2f:54:5d:96:8c:46:66:93:a8:10:98:3a:
                    30:a6:a2:0d:57:65:b4:0f:ab:5f:74:a8:53:44:b9:
                    df:7a:d3:87:0a:a9:a2:d7:1a:58:67:1a:6d:1d:0f:
                    9b:9a:9b:bb:25:07:1f:80:0d:fd:f5:fa:51:d6:6b:
                    79:49:15:2a:79:5d:81:f4:96:2a:30:57:4c:cf:55:
                    cc:85:64:27:fd:e1:0d:b5:cf:92:ca:62:81:60:59:
                    7c:12:d2:78:5e:17:26:1f:3a:fd:56:60:4c:2a:43:
                    57:90:78:a0:c5:f5:c9:52:6c:21:22:94:a4:e5:f3:
                    77:f1:e7:5b:ee:6b:c2:a9:6b:53:64:c0:b9:a6:c3:
                    50:07:bd:d7:ad:01:1b:c0:3f:de:9f:9e:c3:68:c4:
                    75:78:69:2e:da:49:2d:d8:04:14:f1:fd:15:cb:3a:
                    15:08:12:a7:25:55:12:b7:af:10:31:39:c4:db:ba:
                    38:7e:60:6f:30:ea:5f:ac:b8:07:28:cc:19:0c:7d:
                    cb:29:7f:c4:7b:ab:69:f4:34:67:69:c7:17:ff:76:

~/.kube                                                                                                                      14:28:36
❯ awk '/client-certificate-data:/{flag=1} flag && /^[[:space:]]*client-key-data:/{flag=0} flag' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'client-certificate-data:' | \
  cut -d':' -f2- | \
  sed 's/^[[:space:]]*//' | \
  base64 -d > /tmp/decoded-client.crt

~/.kube                                                                                                                      14:28:57
❯ openssl x509 -in /tmp/decoded-client.crt -text -noout | head -30
Certificate:
    Data:
        Version: 3 (0x2)
        Serial Number: 3322358965758446498 (0x2e1b63e0725dcba2)
        Signature Algorithm: sha256WithRSAEncryption
        Issuer: CN = kubernetes
        Validity
            Not Before: Jan  1 07:08:58 2026 GMT
            Not After : Jan  1 07:13:58 2027 GMT
        Subject: O = kubeadm:cluster-admins, CN = kubernetes-admin
        Subject Public Key Info:
            Public Key Algorithm: rsaEncryption
                Public-Key: (2048 bit)
                Modulus:
                    00:aa:92:9a:42:9f:05:41:b1:fd:b5:1f:08:05:09:
                    38:70:18:f1:9d:8a:a2:91:54:de:84:43:08:05:c1:
                    9c:b7:67:d3:28:21:e1:1f:32:44:bf:6f:d3:fc:94:
                    37:06:bd:53:3f:1b:0c:06:c8:39:fe:a5:12:fe:bd:
                    73:9b:36:64:a0:9d:2f:f1:b1:0f:ac:52:37:e0:2c:
                    32:a8:7b:07:6a:01:aa:c1:3e:6f:e1:af:53:33:38:
                    8a:be:b8:6a:35:74:0c:6f:8a:9b:28:dc:e0:7b:e1:
                    c1:25:05:bd:70:8e:aa:2e:e6:32:f5:1b:77:39:a2:
                    29:ed:4c:96:9c:af:63:ab:eb:08:1b:46:22:b5:84:
                    0b:5f:f4:ef:e4:12:7c:0c:14:3f:ef:ba:fe:9c:22:
                    fa:54:3e:d8:8a:a5:00:45:7f:12:84:80:f6:fa:5f:
                    d5:5a:b1:bc:b0:45:9a:2b:94:a8:e8:22:28:94:dd:
                    8d:ef:00:24:23:25:0d:5a:60:34:66:21:a9:af:99:
                    24:c4:db:ef:71:0f:9d:31:7f:dd:37:40:9c:f2:3e:
                    7f:51:96:d1:bc:39:bc:86:13:df:d4:9c:7f:d7:e9:
                    30:f0:3d:da:ed:66:9d:bd:59:7a:75:77:6f:b0:ba:

~/.kube                                                                                                                      14:29:02
❯ awk '/client-key-data:/{flag=1} flag && /^[[:space:]]*token:/{flag=0} flag' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'client-key-data:' | \
  cut -d':' -f2- | \
  sed 's/^[[:space:]]*//' | \
  base64 -d > /tmp/decoded-client.key

~/.kube                                                                                                                      14:29:18
❯ file /tmp/decoded-client.key
/tmp/decoded-client.key: PEM RSA private key

~/.kube                                                                                                                      14:29:22
❯ # Using yq (if installed)
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.clusters[0].cluster.certificate-authority-data' | base64 -d > /tmp/ca.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-certificate-data' | base64 -d > /tmp/client.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-key-data' | base64 -d > /tmp/client.key

# Using grep/sed only
cat /tmp/gatewayapi-kubeconfig.yaml | grep -A1 -B1 'certificate-authority-data:' | tail -1 | base64 -d > /tmp/ca2.crt
zsh: unknown file attribute: i
jq: error: authority/0 is not defined at <top-level>, line 1:
.clusters[0].cluster.certificate-authority-data
jq: error: data/0 is not defined at <top-level>, line 1:
.clusters[0].cluster.certificate-authority-data
jq: 2 compile errors
jq: error: certificate/0 is not defined at <top-level>, line 1:
.users[0].user.client-certificate-data
jq: error: data/0 is not defined at <top-level>, line 1:
.users[0].user.client-certificate-data
jq: 2 compile errors
jq: error: key/0 is not defined at <top-level>, line 1:
.users[0].user.client-key-data
jq: error: data/0 is not defined at <top-level>, line 1:
.users[0].user.client-key-data
jq: 2 compile errors
zsh: command not found: #
base64: invalid input

~/.kube                                                                                                                      14:29:36
❯


play with openssl
- ca key
- csr
- sign the csr

undderstnad the contnet inside

what is cn
what is groups 
how certificate or csr at basica level undersnada

-> how kubeconfig 

-> kubectl config command everytrhign everything!
-> then how kubeconfig looks like differnet way to derive and create
-> create a user -> key, get create a csr request to the kluster 
-> addmin approve it athen create stuff and stuff thign please

pki inspect -( do somethign with some pratcial qustion )

play with openssl
- ca key
- csr
- sign the csr

undderstnad the contnet inside

what is cn
what is groups 
how certificate or csr at basica level undersnada

-> how kubeconfig 

-> kubectl config command everytrhign everything!
-> then how kubeconfig looks like differnet way to derive and create
-> create a user -> key, get create a csr request to the kluster 
-> addmin approve it athen create stuff and stuff thign please

pki inspect -( do somethign with some pratcial qustion )