# Kubeconfig & PKI - Complete Solutions Guide

Solutions for all 20 challenges in `question.md`. Use kind clusters for all exercises.

---

## Challenge 1: Certificate Analysis in Running Cluster

### Setup

```bash
kind create cluster --name cka-cluster
```

### Step 1: Find all certificate files

```bash
docker exec cka-cluster-control-plane ls -la /etc/kubernetes/pki/

# Output includes:
# ca.crt, ca.key                    - Cluster CA
# apiserver.crt, apiserver.key      - API Server cert
# apiserver-etcd-client.crt/key     - API server to etcd auth
# apiserver-kubelet-client.crt/key  - API server to kubelet auth
# front-proxy-ca.crt/key            - Aggregation layer CA
# front-proxy-client.crt/key        - Aggregation layer client
# sa.key, sa.pub                    - Service account signing keys
# etcd/                             - ETCD certificates directory
```

### Step 2: Get CA Common Name

```bash
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -subject

# Output: subject=CN = kubernetes
```

### Step 3: Verify CA is self-signed

```bash
# Compare subject and issuer - if same, it's self-signed
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/ca.crt -noout -subject -issuer

# Output:
# subject=CN = kubernetes
# issuer=CN = kubernetes
# Same subject and issuer = self-signed
```

### Step 4: Check API server certificate issuer

```bash
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -issuer

# Output: issuer=CN = kubernetes
# Issued by the cluster CA
```

### Step 5: Extract CA from kubeconfig

```bash
kubectl config view --raw | grep 'certificate-authority-data' | head -1 | awk '{print $2}' | base64 -d > extracted-ca.crt

openssl x509 -in extracted-ca.crt -noout -dates
# notBefore=...
# notAfter=...
```

### Step 6: Calculate days until expiration

```bash
EXPIRY=$(openssl x509 -in extracted-ca.crt -noout -enddate | cut -d'=' -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
echo "Days until CA expiration: $DAYS_LEFT"
```

### Step 7: List API server SANs (DNS names)

```bash
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A1 "Subject Alternative Name"

# Or extract just DNS names:
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep "DNS:" | tr ',' '\n'
```

### Step 8: List API server SANs (IP addresses)

```bash
docker exec cka-cluster-control-plane \
  openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep "IP Address"
```

### Complete Analysis Script

```bash
#!/bin/bash
# cert-analyzer.sh

CLUSTER_NAME=${1:-cka-cluster}
NODE="${CLUSTER_NAME}-control-plane"
PKI_PATH="/etc/kubernetes/pki"

echo "=== Certificate Analysis for $CLUSTER_NAME ==="

# CA Certificate
echo -e "\n--- Cluster CA ---"
docker exec "$NODE" openssl x509 -in "$PKI_PATH/ca.crt" -noout -subject -issuer -dates

# Check if self-signed
SUBJECT=$(docker exec "$NODE" openssl x509 -in "$PKI_PATH/ca.crt" -noout -subject)
ISSUER=$(docker exec "$NODE" openssl x509 -in "$PKI_PATH/ca.crt" -noout -issuer)
if [[ "$SUBJECT" == "${ISSUER/issuer/subject}" ]]; then
    echo "Self-signed: YES"
else
    echo "Self-signed: NO"
fi

# Days until expiration
EXPIRY=$(docker exec "$NODE" openssl x509 -in "$PKI_PATH/ca.crt" -noout -enddate | cut -d'=' -f2)
EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
CURRENT_EPOCH=$(date +%s)
DAYS=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
echo "Days until expiration: $DAYS"

# API Server Certificate
echo -e "\n--- API Server Certificate ---"
docker exec "$NODE" openssl x509 -in "$PKI_PATH/apiserver.crt" -noout -subject -issuer

echo -e "\nSANs (DNS names):"
docker exec "$NODE" openssl x509 -in "$PKI_PATH/apiserver.crt" -text -noout | grep "DNS:" | tr ',' '\n' | sed 's/^[[:space:]]*//'

echo -e "\nSANs (IP addresses):"
docker exec "$NODE" openssl x509 -in "$PKI_PATH/apiserver.crt" -text -noout | grep "IP Address" | tr ',' '\n' | sed 's/^[[:space:]]*//'
```

### Why multiple SANs are needed

The API server certificate needs multiple DNS names and IPs because clients connect via different addresses:
- `kubernetes` - internal service name
- `kubernetes.default` - namespaced service name
- `kubernetes.default.svc` - full service name
- `kubernetes.default.svc.cluster.local` - FQDN
- `localhost` - local connections
- Node hostname - external access
- Cluster IP (10.96.0.1) - service IP
- Node IP - direct node access

### Cleanup

```bash
kind delete cluster --name cka-cluster
```

---

## Challenge 2: Multi-Cluster Kubeconfig Management

### Step 1: Create three clusters

```bash
kind create cluster --name prod-cluster
kind create cluster --name staging-cluster
kind create cluster --name dev-cluster
```

### Step 2: Get individual kubeconfigs

```bash
kind get kubeconfig --name prod-cluster > prod.kubeconfig
kind get kubeconfig --name staging-cluster > staging.kubeconfig
kind get kubeconfig --name dev-cluster > dev.kubeconfig
```

### Step 3: Merge kubeconfigs

```bash
# Set KUBECONFIG to all files
export KUBECONFIG=prod.kubeconfig:staging.kubeconfig:dev.kubeconfig

# Merge and flatten into single file
kubectl config view --flatten > merged.kubeconfig

# Use merged config
export KUBECONFIG=merged.kubeconfig
```

### Step 4: Create namespaces in each cluster

```bash
kubectl config use-context kind-prod-cluster
kubectl create namespace production

kubectl config use-context kind-staging-cluster
kubectl create namespace staging

kubectl config use-context kind-dev-cluster
kubectl create namespace development
```

### Step 5: Set default namespaces per context

```bash
kubectl config set-context kind-prod-cluster --namespace=production
kubectl config set-context kind-staging-cluster --namespace=staging
kubectl config set-context kind-dev-cluster --namespace=development
```

### Step 6: Context switching function

```bash
# Add to ~/.bashrc or ~/.zshrc
kctx() {
    if [ -z "$1" ]; then
        # Interactive selection
        local ctx=$(kubectl config get-contexts -o name | fzf --prompt="Select context: ")
        if [ -n "$ctx" ]; then
            kubectl config use-context "$ctx"
        fi
    else
        kubectl config use-context "$1"
    fi
    
    # Show current context info
    echo "---"
    echo "Cluster:   $(kubectl config view --minify -o jsonpath='{.clusters[0].name}')"
    echo "User:      $(kubectl config view --minify -o jsonpath='{.users[0].name}')"
    echo "Namespace: $(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')"
}

# Simple version without fzf
kctx-simple() {
    if [ -z "$1" ]; then
        echo "Available contexts:"
        kubectl config get-contexts
        return
    fi
    kubectl config use-context "$1"
    echo "Switched to: $1"
    echo "Namespace: $(kubectl config view --minify -o jsonpath='{.contexts[0].context.namespace}')"
}
```

### Step 7: Verify switching

```bash
kctx kind-prod-cluster
kubectl get pods  # runs in production namespace

kctx kind-staging-cluster
kubectl get pods  # runs in staging namespace

kctx kind-dev-cluster
kubectl get pods  # runs in development namespace
```

### Cleanup

```bash
kind delete clusters prod-cluster staging-cluster dev-cluster
```

---

## Challenge 3: Create Users Using Kubernetes CSR API

### Setup

```bash
kind create cluster --name user-cluster
mkdir -p users/{alice,bob,admin-carol}
```

### Step 1: Generate private keys

```bash
openssl genrsa -out users/alice/alice.key 2048
openssl genrsa -out users/bob/bob.key 2048
openssl genrsa -out users/admin-carol/admin-carol.key 2048
```

### Step 2: Create CSRs with CN and O fields

```bash
# Alice - developer
openssl req -new -key users/alice/alice.key -out users/alice/alice.csr \
  -subj "/CN=alice/O=developers"

# Bob - developer
openssl req -new -key users/bob/bob.key -out users/bob/bob.csr \
  -subj "/CN=bob/O=developers"

# Carol - admin
openssl req -new -key users/admin-carol/admin-carol.key -out users/admin-carol/admin-carol.csr \
  -subj "/CN=admin-carol/O=kubeadm:cluster-admins"
```

### Step 3: Submit CSRs to Kubernetes

```bash
# Function to create CSR object
create_k8s_csr() {
    local name=$1
    local csr_file=$2
    
    cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${name}-csr
spec:
  request: $(cat "$csr_file" | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
}

create_k8s_csr alice users/alice/alice.csr
create_k8s_csr bob users/bob/bob.csr
create_k8s_csr admin-carol users/admin-carol/admin-carol.csr
```

### Step 4: Approve CSRs

```bash
kubectl certificate approve alice-csr
kubectl certificate approve bob-csr
kubectl certificate approve admin-carol-csr

# Verify approval
kubectl get csr
```

### Step 5: Extract signed certificates

```bash
kubectl get csr alice-csr -o jsonpath='{.status.certificate}' | base64 -d > users/alice/alice.crt
kubectl get csr bob-csr -o jsonpath='{.status.certificate}' | base64 -d > users/bob/bob.crt
kubectl get csr admin-carol-csr -o jsonpath='{.status.certificate}' | base64 -d > users/admin-carol/admin-carol.crt
```

### Step 6: Add users to kubeconfig

```bash
# Get cluster info
CLUSTER_NAME="kind-user-cluster"
API_SERVER=$(kubectl config view -o jsonpath="{.clusters[?(@.name=='$CLUSTER_NAME')].cluster.server}")

# Add credentials
kubectl config set-credentials alice \
  --client-certificate=users/alice/alice.crt \
  --client-key=users/alice/alice.key

kubectl config set-credentials bob \
  --client-certificate=users/bob/bob.crt \
  --client-key=users/bob/bob.key

kubectl config set-credentials admin-carol \
  --client-certificate=users/admin-carol/admin-carol.crt \
  --client-key=users/admin-carol/admin-carol.key
```

### Step 7: Create contexts

```bash
kubectl config set-context alice-context --cluster=$CLUSTER_NAME --user=alice
kubectl config set-context bob-context --cluster=$CLUSTER_NAME --user=bob
kubectl config set-context admin-carol-context --cluster=$CLUSTER_NAME --user=admin-carol
```

### Step 8: Create RBAC permissions

```bash
# Role for developers (read-only pods)
cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: pod-reader
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: developers-pod-reader
subjects:
- kind: Group
  name: developers
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-carol-cluster-admin
subjects:
- kind: Group
  name: kubeadm:cluster-admins
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
```

### Step 9: Test permissions

```bash
# Test alice (developer) - can list pods
kubectl --context=alice-context get pods -A
# Should work

# Test alice - cannot delete pods
kubectl --context=alice-context delete pod test-pod 2>&1
# Error: pods "test-pod" is forbidden

# Test alice - cannot access nodes
kubectl --context=alice-context get nodes 2>&1
# Error: nodes is forbidden

# Test admin-carol - full access
kubectl --context=admin-carol-context get nodes
# Should work

kubectl --context=admin-carol-context delete pod test-pod
# Should work (if pod exists)
```

### Cleanup

```bash
kind delete cluster --name user-cluster
rm -rf users/
```

---

## Challenge 4: Build a User Provisioning Automation Script

### Complete Script

```bash
#!/bin/bash
# provision-user.sh - Automated user provisioning with certificates and RBAC

set -e

# Arguments
USERNAME=${1:?Usage: $0 <username> <group> [cluster-context]}
GROUP=${2:?Usage: $0 <username> <group> [cluster-context]}
CLUSTER_CONTEXT=${3:-$(kubectl config current-context)}

# Directories
USER_DIR="users/${USERNAME}"
mkdir -p "$USER_DIR"

echo "=== User Provisioning Script ==="
echo "Username: $USERNAME"
echo "Group: $GROUP"
echo "Cluster: $CLUSTER_CONTEXT"
echo ""

# Step 1: Generate private key
echo "[1/10] Generating private key..."
openssl genrsa -out "$USER_DIR/${USERNAME}.key" 2048 2>/dev/null
chmod 600 "$USER_DIR/${USERNAME}.key"
echo "  Key: $USER_DIR/${USERNAME}.key"

# Step 2: Create CSR
echo "[2/10] Creating certificate signing request..."
openssl req -new -key "$USER_DIR/${USERNAME}.key" -out "$USER_DIR/${USERNAME}.csr" \
  -subj "/CN=${USERNAME}/O=${GROUP}"
echo "  CSR created with CN=${USERNAME}, O=${GROUP}"

# Step 3: Submit CSR to Kubernetes
echo "[3/10] Submitting CSR to Kubernetes..."
CSR_NAME="${USERNAME}-csr-$(date +%s)"
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  request: $(cat "$USER_DIR/${USERNAME}.csr" | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF
echo "  CSR submitted: $CSR_NAME"

# Step 4: Approve CSR
echo "[4/10] Approving CSR..."
kubectl certificate approve "$CSR_NAME"
echo "  CSR approved"

# Step 5: Wait for certificate
echo "[5/10] Waiting for certificate..."
for i in {1..30}; do
    CERT=$(kubectl get csr "$CSR_NAME" -o jsonpath='{.status.certificate}' 2>/dev/null)
    if [ -n "$CERT" ]; then
        break
    fi
    sleep 1
done

if [ -z "$CERT" ]; then
    echo "  Timeout waiting for certificate"
    exit 1
fi

# Step 6: Extract certificate
echo "[6/10] Extracting signed certificate..."
kubectl get csr "$CSR_NAME" -o jsonpath='{.status.certificate}' | base64 -d > "$USER_DIR/${USERNAME}.crt"
echo "  Certificate: $USER_DIR/${USERNAME}.crt"

# Step 7: Configure kubeconfig
echo "[7/10] Configuring kubeconfig..."
CLUSTER_NAME=$(kubectl config view -o jsonpath="{.contexts[?(@.name=='$CLUSTER_CONTEXT')].context.cluster}")

kubectl config set-credentials "$USERNAME" \
  --client-certificate="$USER_DIR/${USERNAME}.crt" \
  --client-key="$USER_DIR/${USERNAME}.key"

kubectl config set-context "${USERNAME}-context" \
  --cluster="$CLUSTER_NAME" \
  --user="$USERNAME"
echo "  Context created: ${USERNAME}-context"

# Step 8: Create RBAC
echo "[8/10] Creating RBAC permissions..."
case "$GROUP" in
    "developers"|"dev")
        cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USERNAME}-view
subjects:
- kind: User
  name: ${USERNAME}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: view
  apiGroup: rbac.authorization.k8s.io
EOF
        echo "  Assigned 'view' ClusterRole"
        ;;
    "admins"|"kubeadm:cluster-admins")
        cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: ${USERNAME}-cluster-admin
subjects:
- kind: User
  name: ${USERNAME}
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF
        echo "  Assigned 'cluster-admin' ClusterRole"
        ;;
    *)
        echo "  Unknown group '$GROUP' - no RBAC created"
        ;;
esac

# Step 9: Test authentication
echo "[9/10] Testing authentication..."
if kubectl --context="${USERNAME}-context" auth can-i get pods &>/dev/null; then
    echo "  Authentication successful"
else
    echo "  Authentication failed"
fi

# Step 10: Summary
echo "[10/10] Complete!"
echo ""
echo "=== Summary ==="
echo "User:        $USERNAME"
echo "Group:       $GROUP"
echo "Context:     ${USERNAME}-context"
echo "Private key: $USER_DIR/${USERNAME}.key"
echo "Certificate: $USER_DIR/${USERNAME}.crt"
echo ""
echo "WARNING: Keep the private key secure!"
echo "Usage: kubectl --context=${USERNAME}-context <command>"
```

### Test the script

```bash
chmod +x provision-user.sh

./provision-user.sh alice developers
./provision-user.sh bob developers
./provision-user.sh carol admins

# Verify
kubectl --context=alice-context get pods
kubectl --context=carol-context get nodes
```

---

## Challenge 5: Troubleshoot Certificate Mismatches

### Scenario 1: Certificate signed by unknown authority

**Diagnosis:**

```bash
# User gets error:
# x509: certificate signed by unknown authority

# Check if user cert is signed by cluster CA
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > cluster-ca.crt

# Verify user cert against cluster CA
openssl verify -CAfile cluster-ca.crt user.crt
# If fails: user cert was NOT signed by this CA
```

**Fix:**

```bash
# Option 1: Re-sign user cert with cluster CA
# Option 2: Update kubeconfig with correct CA
kubectl config set-cluster <cluster-name> --certificate-authority=correct-ca.crt
```

### Scenario 2: Hostname mismatch

**Diagnosis:**

```bash
# Error: x509: certificate is valid for X, not Y

# Check what SANs are in the cert
openssl x509 -in apiserver.crt -text -noout | grep -A1 "Subject Alternative Name"

# Compare with the hostname being used
kubectl config view -o jsonpath='{.clusters[0].cluster.server}'
```

**Fix:**

```bash
# Use a hostname that's in the certificate SAN
# Or regenerate cert with correct SANs
```

### Scenario 3: Missing context

**Fix:**

```bash
# Create the missing context
kubectl config set-context <context-name> \
  --cluster=<cluster-name> \
  --user=<user-name> \
  --namespace=<namespace>
```

---

## Challenge 6: Monitor Certificate Expiration

### Expiration Monitoring Script

```bash
#!/bin/bash
# cert-monitor.sh - Monitor certificate expiration

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

echo "=== Certificate Expiration Report ==="
echo "Generated: $(date)"
echo ""

USERS=$(kubectl config view -o jsonpath='{.users[*].name}')

printf "%-20s %-25s %-10s %s\n" "USER" "EXPIRES" "DAYS LEFT" "STATUS"
printf "%-20s %-25s %-10s %s\n" "----" "-------" "---------" "------"

for user in $USERS; do
    CERT_DATA=$(kubectl config view --raw -o jsonpath="{.users[?(@.name=='$user')].user.client-certificate-data}" 2>/dev/null)
    
    if [ -z "$CERT_DATA" ]; then
        CERT_FILE=$(kubectl config view -o jsonpath="{.users[?(@.name=='$user')].user.client-certificate}" 2>/dev/null)
        if [ -n "$CERT_FILE" ] && [ -f "$CERT_FILE" ]; then
            CERT_DATA=$(cat "$CERT_FILE" | base64)
        else
            printf "%-20s %-25s %-10s %s\n" "$user" "N/A" "N/A" "NO CERT"
            continue
        fi
    fi
    
    EXPIRY=$(echo "$CERT_DATA" | base64 -d | openssl x509 -noout -enddate 2>/dev/null | cut -d'=' -f2)
    
    if [ -z "$EXPIRY" ]; then
        printf "%-20s %-25s %-10s %s\n" "$user" "INVALID" "N/A" "ERROR"
        continue
    fi
    
    EXPIRY_EPOCH=$(date -d "$EXPIRY" +%s)
    CURRENT_EPOCH=$(date +%s)
    DAYS_LEFT=$(( ($EXPIRY_EPOCH - $CURRENT_EPOCH) / 86400 ))
    
    if [ $DAYS_LEFT -lt 0 ]; then
        STATUS="${RED}EXPIRED${NC}"
    elif [ $DAYS_LEFT -lt 7 ]; then
        STATUS="${RED}CRITICAL${NC}"
    elif [ $DAYS_LEFT -lt 30 ]; then
        STATUS="${YELLOW}WARNING${NC}"
    else
        STATUS="${GREEN}OK${NC}"
    fi
    
    printf "%-20s %-25s %-10s %b\n" "$user" "$EXPIRY" "$DAYS_LEFT" "$STATUS"
done
```

---

## Challenge 7: Certificate Renewal Workflow

### Renewal process

```bash
USERNAME="alice"
USER_DIR="users/$USERNAME"

# Generate new private key
openssl genrsa -out "$USER_DIR/${USERNAME}-new.key" 2048

# Create new CSR with same CN/O
OLD_SUBJECT=$(openssl x509 -in "$USER_DIR/${USERNAME}.crt" -noout -subject | sed 's/subject=//')
openssl req -new -key "$USER_DIR/${USERNAME}-new.key" -out "$USER_DIR/${USERNAME}-new.csr" \
  -subj "$OLD_SUBJECT"

# Submit to Kubernetes
CSR_NAME="${USERNAME}-renewal-$(date +%s)"
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: ${CSR_NAME}
spec:
  request: $(cat "$USER_DIR/${USERNAME}-new.csr" | base64 | tr -d '\n')
  signerName: kubernetes.io/kube-apiserver-client
  usages:
  - client auth
EOF

# Approve
kubectl certificate approve "$CSR_NAME"

# Extract new certificate
kubectl get csr "$CSR_NAME" -o jsonpath='{.status.certificate}' | base64 -d > "$USER_DIR/${USERNAME}-new.crt"

# Update kubeconfig
kubectl config set-credentials "$USERNAME" \
  --client-certificate="$USER_DIR/${USERNAME}-new.crt" \
  --client-key="$USER_DIR/${USERNAME}-new.key"

# Verify
kubectl --context=${USERNAME}-context auth can-i get pods
```

### Compare certificates

```bash
echo "=== Old Certificate ==="
openssl x509 -in "$USER_DIR/${USERNAME}.crt" -noout -subject -dates -serial

echo "=== New Certificate ==="
openssl x509 -in "$USER_DIR/${USERNAME}-new.crt" -noout -subject -dates -serial

# Same: Subject (CN, O)
# Different: Serial, Dates
```

---

## Challenge 8: Custom Certificate with Specific SANs

### OpenSSL Config File

```bash
cat > custom-cert.cnf <<EOF
[req]
distinguished_name = req_distinguished_name
req_extensions = v3_req
prompt = no

[req_distinguished_name]
CN = custom-server

[v3_req]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
extendedKeyUsage = serverAuth, clientAuth
subjectAltName = @alt_names

[alt_names]
DNS.1 = custom-server
DNS.2 = custom-server.default
DNS.3 = custom-server.default.svc
DNS.4 = custom-server.default.svc.cluster.local
DNS.5 = localhost
IP.1 = 10.96.0.100
IP.2 = 127.0.0.1
IP.3 = 192.168.1.100
EOF
```

### Generate Certificate

```bash
# Generate key
openssl genrsa -out custom-server.key 2048

# Create CSR with config
openssl req -new -key custom-server.key -out custom-server.csr -config custom-cert.cnf

# Sign with cluster CA
docker cp <cluster>-control-plane:/etc/kubernetes/pki/ca.crt .
docker cp <cluster>-control-plane:/etc/kubernetes/pki/ca.key .

openssl x509 -req -in custom-server.csr -CA ca.crt -CAkey ca.key \
  -CAcreateserial -out custom-server.crt -days 365 \
  -extensions v3_req -extfile custom-cert.cnf
```

### Verify SANs

```bash
openssl x509 -in custom-server.crt -text -noout | grep -A15 "X509v3 extensions"
```

---

## Challenge 9: Embedded vs Referenced Certificates

### Embedded certificates

```bash
# Embedded format in kubeconfig:
# client-certificate-data: LS0tLS1CRUdJTi...
# client-key-data: LS0tLS1CRUdJTi...

kubectl config view --raw  # Shows base64 encoded data inline
```

### Referenced certificates

```bash
# Convert to file references
kubectl config set-credentials alice \
  --client-certificate=/path/to/alice.crt \
  --client-key=/path/to/alice.key

# Now kubeconfig shows:
# client-certificate: /path/to/alice.crt
# client-key: /path/to/alice.key
```

### When to use each

- **Embedded**: Distribution, portability, single-file sharing
- **Referenced**: Local development, easier cert rotation, security

---

## Challenge 10: Complete User Lifecycle

Use provisioning script from Challenge 4, monitoring from Challenge 6, renewal from Challenge 7.

### User removal

```bash
USERNAME="alice"

# Remove from kubeconfig
kubectl config delete-user "$USERNAME"
kubectl config delete-context "${USERNAME}-context"

# Remove RBAC
kubectl delete clusterrolebinding "${USERNAME}-view" 2>/dev/null
kubectl delete clusterrolebinding "${USERNAME}-cluster-admin" 2>/dev/null

# Delete local files
rm -rf "users/$USERNAME"

echo "User $USERNAME removed"
```

---

## Challenge 11: CSR Management in Kubernetes

### CSR operations

```bash
# List CSRs
kubectl get csr

# View details
kubectl describe csr <csr-name>

# Decode original request
kubectl get csr <csr-name> -o jsonpath='{.spec.request}' | base64 -d | openssl req -text -noout

# Approve/Deny
kubectl certificate approve <csr-name>
kubectl certificate deny <csr-name>

# Delete
kubectl delete csr <csr-name>
```

### Auto-approval script

```bash
#!/bin/bash
# auto-approve-csr.sh

ALLOWED_GROUPS="developers,admins"

while true; do
    for csr in $(kubectl get csr -o jsonpath='{.items[?(@.status.conditions==null)].metadata.name}'); do
        REQUEST=$(kubectl get csr "$csr" -o jsonpath='{.spec.request}' | base64 -d)
        ORG=$(echo "$REQUEST" | openssl req -noout -subject 2>/dev/null | grep -oP '(?<=O = )[^,]+')
        
        if echo "$ALLOWED_GROUPS" | grep -q "$ORG"; then
            echo "Auto-approving CSR $csr (group: $ORG)"
            kubectl certificate approve "$csr"
        fi
    done
    sleep 10
done
```

---

## Challenge 12: Multi-Cluster User Management

### Create same user in multiple clusters

```bash
# Create clusters
kind create cluster --name prod
kind create cluster --name dev

# Provision user in each
kubectl config use-context kind-prod
./provision-user.sh shared-user developers

kubectl config use-context kind-dev
./provision-user.sh shared-user developers
```

### Different RBAC per cluster

```bash
# Prod: read-only
kubectl --context=kind-prod create clusterrolebinding shared-user-prod \
  --clusterrole=view --user=shared-user

# Dev: full access
kubectl --context=kind-dev create clusterrolebinding shared-user-dev \
  --clusterrole=cluster-admin --user=shared-user
```

---

## Challenge 13: Kubeconfig Recovery and Backup

### Backup script

```bash
#!/bin/bash
BACKUP_DIR="${HOME}/.kube/backups"
mkdir -p "$BACKUP_DIR"

BACKUP_FILE="${BACKUP_DIR}/kubeconfig-$(date +%Y%m%d-%H%M%S).bak"
cp "${HOME}/.kube/config" "$BACKUP_FILE"
echo "Backup: $BACKUP_FILE"

# Keep only last 10 backups
ls -t "${BACKUP_DIR}"/*.bak | tail -n +11 | xargs -r rm
```

### Validation script

```bash
#!/bin/bash
for ctx in $(kubectl config get-contexts -o name); do
    echo -n "Testing $ctx... "
    if kubectl --context="$ctx" cluster-info &>/dev/null; then
        echo "OK"
    else
        echo "FAILED"
    fi
done
```

---

## Challenge 14: Understanding Certificate Authorities

### Extract all CAs

```bash
NODE="<cluster>-control-plane"

docker cp "$NODE":/etc/kubernetes/pki/ca.crt ./cluster-ca.crt
docker cp "$NODE":/etc/kubernetes/pki/front-proxy-ca.crt ./front-proxy-ca.crt
docker cp "$NODE":/etc/kubernetes/pki/etcd/ca.crt ./etcd-ca.crt
```

### Validate cert chains

```bash
#!/bin/bash
NODE="${1}-control-plane"
PKI="/etc/kubernetes/pki"

verify_cert() {
    local cert=$1
    local ca=$2
    local name=$3
    
    if docker exec "$NODE" openssl verify -CAfile "$ca" "$cert" &>/dev/null; then
        echo "OK: $name"
    else
        echo "FAIL: $name"
    fi
}

verify_cert "$PKI/apiserver.crt" "$PKI/ca.crt" "API Server"
verify_cert "$PKI/front-proxy-client.crt" "$PKI/front-proxy-ca.crt" "Front Proxy"
verify_cert "$PKI/etcd/server.crt" "$PKI/etcd/ca.crt" "ETCD Server"
```

---

## Challenge 15: Real-World Incident Response

### Incident 1: Kubelet certificate expires

```bash
# Diagnosis
kubectl get nodes  # Node shows NotReady
docker exec <node> openssl x509 -in /var/lib/kubelet/pki/kubelet-client.crt -noout -dates

# Fix: Restart kubelet (triggers rotation if enabled)
docker exec <node> systemctl restart kubelet
```

### Incident 2: User certificate theft

```bash
# Revoke access
kubectl delete clusterrolebinding <user>-binding
kubectl config delete-user <user>
kubectl config delete-context <user>-context

# Provision new certificate
./provision-user.sh <user> <group>
```

### Incident 3: Wrong SANs

```bash
# Diagnosis
openssl x509 -in server.crt -text -noout | grep -A1 "Subject Alternative Name"

# Fix: Regenerate with correct SANs using Challenge 8 process
```

---

## Challenge 16: Kubelet Client Certificate Rotation

### Find and examine kubelet cert

```bash
docker exec <node> ls -la /var/lib/kubelet/pki/
docker exec <node> openssl x509 -in /var/lib/kubelet/pki/kubelet-client-current.pem -noout -subject -dates
# subject=O = system:nodes, CN = system:node:<nodename>
```

### Monitoring script

```bash
#!/bin/bash
for node in $(kubectl get nodes -o name | cut -d'/' -f2); do
    CERT="/var/lib/kubelet/pki/kubelet-client-current.pem"
    EXPIRY=$(docker exec "$node" openssl x509 -in "$CERT" -noout -enddate 2>/dev/null | cut -d'=' -f2)
    echo "Node: $node - Expires: $EXPIRY"
done
```

---

## Challenge 17: Service Account Token and RBAC

### Create SA with kubeconfig

```bash
kubectl create namespace test-ns
kubectl create serviceaccount test-sa -n test-ns

TOKEN=$(kubectl create token test-sa -n test-ns)
API_SERVER=$(kubectl config view -o jsonpath='{.clusters[0].cluster.server}')
CA_DATA=$(kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')

cat > sa-kubeconfig.yaml <<EOF
apiVersion: v1
kind: Config
clusters:
- cluster:
    certificate-authority-data: $CA_DATA
    server: $API_SERVER
  name: cluster
contexts:
- context:
    cluster: cluster
    user: test-sa
    namespace: test-ns
  name: test-sa-context
current-context: test-sa-context
users:
- name: test-sa
  user:
    token: $TOKEN
EOF

# Add RBAC
kubectl create role pod-reader --verb=get,list --resource=pods -n test-ns
kubectl create rolebinding test-sa-pods --role=pod-reader --serviceaccount=test-ns:test-sa -n test-ns
```

---

## Challenge 18: System Component Authentication

### Extract component certificates

```bash
NODE="<cluster>-control-plane"

# Controller Manager
docker exec "$NODE" cat /etc/kubernetes/controller-manager.conf | \
  grep client-certificate-data | awk '{print $2}' | base64 -d | \
  openssl x509 -noout -subject
# subject=CN = system:kube-controller-manager

# Scheduler
docker exec "$NODE" cat /etc/kubernetes/scheduler.conf | \
  grep client-certificate-data | awk '{print $2}' | base64 -d | \
  openssl x509 -noout -subject
# subject=CN = system:kube-scheduler
```

---

## Challenge 19: Network Policy and mTLS

### Install Calico and create policies

```bash
kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.27.0/manifests/calico.yaml

# Default deny
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: default-deny
  namespace: backend
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  - Egress
EOF

# Allow frontend to backend
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-frontend
  namespace: backend
spec:
  podSelector: {}
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: frontend
EOF
```

---

## Challenge 20: Audit Logging

### Kind config with audit

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: ClusterConfiguration
    apiServer:
      extraArgs:
        audit-log-path: /var/log/kubernetes/audit.log
        audit-policy-file: /etc/kubernetes/audit-policy.yaml
      extraVolumes:
      - name: audit-policy
        hostPath: /etc/kubernetes/audit-policy.yaml
        mountPath: /etc/kubernetes/audit-policy.yaml
      - name: audit-logs
        hostPath: /var/log/kubernetes
        mountPath: /var/log/kubernetes
  extraMounts:
  - hostPath: ./audit-policy.yaml
    containerPath: /etc/kubernetes/audit-policy.yaml
```

### Parse audit logs

```bash
docker exec <node> cat /var/log/kubernetes/audit.log | \
  jq -r 'select(.user.username != null) | "\(.requestReceivedTimestamp) \(.user.username) \(.verb) \(.objectRef.resource)"' | tail -20
```

---

## Quick Reference

```bash
# View kubeconfig
kubectl config view
kubectl config view --raw

# Context management
kubectl config get-contexts
kubectl config use-context <name>
kubectl config set-context <name> --cluster=X --user=Y --namespace=Z

# Certificate inspection
openssl x509 -in cert.crt -text -noout
openssl x509 -in cert.crt -noout -subject -issuer -dates

# CSR management
kubectl get csr
kubectl certificate approve <name>
kubectl certificate deny <name>

# Extract cert from kubeconfig
kubectl config view --raw -o jsonpath='{.users[0].user.client-certificate-data}' | base64 -d
```

---

**Last Updated:** January 10, 2026
