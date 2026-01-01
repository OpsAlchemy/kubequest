apiVersion: v1  # Config file format version
kind: Config   # This is a kubeconfig file

clusters:      # List of clusters you can access
- cluster:     # One cluster entry
    certificate-authority-data: <BASE64>  # Cluster's CA certificate
    server: https://127.0.0.1:39619       # API Server endpoint
  name: kind-gatewayapi                   # Reference name for this cluster

users:         # List of user identities
- name: kind-gatewayapi  # User reference name
  user:
    client-certificate-data: <BASE64>  # Your client certificate
    client-key-data: <BASE64>          # Your PRIVATE KEY (RSA/EC)

contexts:      # Which user to use with which cluster
- context:
    cluster: kind-gatewayapi  # Use this cluster
    user: kind-gatewayapi     # As this user
  name: kind-gatewayapi       # Context name

current-context: kind-gatewayapi  # Currently active context



# Extract CA cert from kubeconfig and decode
sed -n '/certificate-authority-data:/,/^[[:space:]]*server:/p' /tmp/gatewayapi-kubeconfig.yaml | \
  grep 'certificate-authority-data:' | \
  cut -d':' -f2- | \
  tr -d ' ' | \
  base64 -d > /tmp/decoded-ca.crt

# Or simpler way:
grep 'certificate-authority-data:' /tmp/gatewayapi-kubeconfig.yaml | \
  cut -d':' -f2- | \
  sed 's/^[[:space:]]*//' | \
  base64 -d > /tmp/decoded-ca.crt

# View the decoded certificate
openssl x509 -in /tmp/decoded-ca.crt -text -noout | head -30







# Using yq (if installed)
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.clusters[0].cluster.certificate-authority-data' | base64 -d > /tmp/ca.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-certificate-data' | base64 -d > /tmp/client.crt
cat /tmp/gatewayapi-kubeconfig.yaml | yq '.users[0].user.client-key-data' | base64 -d > /tmp/client.key

# Using grep/sed only
cat /tmp/gatewayapi-kubeconfig.yaml | grep -A1 -B1 'certificate-authority-data:' | tail -1 | base64 -d > /tmp/ca2.crt

kind get kubeconfig --name=gatewayapi > /tmp/gatewayapi-kubeconfig.yaml

----


# Navigate to the directory
cd "/mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/05-kubeconfig"

# Create new user directory
mkdir -p new-user-certs
cd new-user-certs

# 1. Generate user private key
openssl genrsa -out dev-user.key 2048

# 2. Create CSR
openssl req -new -key dev-user.key -out dev-user.csr \
  -subj "/CN=vikash-dev/O=development-team"

# 3. Encode CSR for Kubernetes
CSR_BASE64=$(cat dev-user.csr | base64 | tr -d '\n')

# 4. Create CSR YAML
cat > dev-user-csr.yaml <<EOF
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: vikash-dev-csr
spec:
  request: $CSR_BASE64
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 86400  # 1 day
  usages:
  - client auth
  groups:
  - development-team
  - system:authenticated
  username: vikash-dev
EOF

# 5. Submit CSR to Kubernetes
kubectl apply -f dev-user-csr.yaml

# 6. Approve the CSR (as admin)
kubectl certificate approve vikash-dev-csr

# 7. Wait and get the signed certificate
kubectl get csr vikash-dev-csr -o jsonpath='{.status.certificate}' | base64 -d > dev-user.crt

# 8. Verify the certificate
openssl x509 -in dev-user.crt -text -noout

# 9. Create kubeconfig for new user
# Get cluster info from current kubeconfig
KUBECONFIG=~/.kube/config
SERVER=$(kubectl config view --minify -o jsonpath='{.clusters[0].cluster.server}')
CA_DATA=$(kubectl config view --minify --raw -o json | jq -r '.clusters[0].cluster."certificate-authority-data"')

echo $SERVER
echo $CA_DATA

# Create new kubeconfig
cat > vikash-dev-kubeconfig.yaml <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: $CA_DATA
    server: $SERVER
  name: kind-gatewayapi
contexts:
- context:
    cluster: kind-gatewayapi
    user: vikash-dev
  name: vikash-dev@kind-gatewayapi
current-context: vikash-dev@kind-gatewayapi
kind: Config
preferences: {}
users:
- name: vikash-dev
  user:
    client-certificate-data: $(cat dev-user.crt | base64 | tr -d '\n')
    client-key-data: $(cat dev-user.key | base64 | tr -d '\n')
EOF

# 10. Test the new kubeconfig
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl get pods


# 1. Bind vikash-dev to cluster-admin ClusterRole
cat > vikash-dev-admin.yaml <<EOF
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: vikash-dev-admin
subjects:
- kind: User
  name: vikash-dev
  apiGroup: rbac.authorization.k8s.io
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF

# 2. Apply as current admin
kubectl apply -f vikash-dev-admin.yaml

# 3. Test with new user's kubeconfig
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl get pods -A
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl get nodes
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl get all --all-namespaces

# 4. Try creating something
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl create deployment nginx --image=nginx
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl get deployments
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl delete deployment nginx

# 5. Check what permissions vikash-dev has
KUBECONFIG=vikash-dev-kubeconfig.yaml kubectl auth can-i --list