# Question 1

cat <<EOF > multinode.yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
# One control plane node and three "workers".
#
# While these will not add more real compute capacity and
# have limited isolation, this can be useful for testing
# rolling updates etc.
#
# The API-server and other control plane components will be
# on the control-plane node.
#
# You probably don't need this unless you are testing Kubernetes itself.
nodes:
- role: control-plane
- role: worker
EOF

kind create cluster --name kubeconfig --config multinode.yaml --image kindest/node:v1.34.0 || true

docker cp kubeconfig-control-plane:/etc/kubernetes/pki sol01/

openssl x509 -in sol01/pki/ca.crt -noout
openssl x509 -in sol01/pki/ca.crt -noout -subject
openssl x509 -in sol01/pki/ca.crt -noout -issuer
openssl x509 -in sol01/pki/ca.crt -noout -dates

a=$(openssl x509 -in sol01/pki/ca.crt -noout -subject)
b=$(openssl x509 -in sol01/pki/ca.crt -noout -subject)
if [ "$a" = "$b" ]; then
  echo "same"
else
  echo "different"
fi

kubectl config view --raw | grep 'certificate-authority-data' | head -1 | awk '{print $2}' | base64 -d > sol01/derived-ca.crt
kubectl config view --raw | grep 'certificate-authority-data' | head -1 | awk '{print $2}' | base64 -d | openssl x509 -noout -subject

openssl x509 -in sol01/pki/ca.crt -noout -dates
openssl x509 -in sol01/pki/ca.crt -noout -text

openssl x509 -in sol01/pki/apiserver.crt -text -noout | grep -A10 "Subject Alternative Name"
openssl x509 -in sol01/pki/ca.crt -noout -text \
| sed -n '/Subject Alternative Name/,+1p'

openssl x509 -in sol01/pki/apiserver.crt -text | grep "DNS" | sed 's/.*DNS://g' | tr ',' '\n'

openssl x509 -in sol01/pki/apiserver.crt -text | grep "IP Address:" | sed 's/.*IP Address://g'

## Cleanup ques1
kind delete clusters  kubeconfig
# Question 2
kind create cluster --name prod-cluster --image kindest/node:v1.34.0
kind create cluster --name staging-cluster --image kindest/node:v1.34.0
kind create cluster --name dev-cluster --image kindest/node:v1.34.0
mkdir -p sol02
# for node in staging-cluster-control-plane dev-cluster-control-plane prod-cluster-control-plane; do
#      docker cp $node:/etc/kubernetes/admin.conf sol02/$node.conf
# done

for node in staging-cluster-control-plane dev-cluster-control-plane prod-cluster-control-plane; do
  echo "$node"
  # docker exec "$node" ls -la /etc/kubernetes/pki
  docker cp $node:/etc/kubernetes/admin.conf sol02/$node.conf
done

base_dir="/home/vagabond/peak/kubequest/cka/solutions/05-kubeconfig/sol02"
export KUBECONFIG="$base_dir/dev-cluster-control-plane.conf:$base_dir/prod-cluster-control-plane.conf:$base_dir/staging-cluster-control-plane.conf"
kubectl config view

export KUBECONFIG="$base_dir/dev-cluster-control-plane.conf"

kind export kubeconfig --name dev-cluster

#---
kind get kubeconfig --name prod-cluster > prod.kubeconfig
kind get kubeconfig --name staging-cluster > staging.kubeconfig
kind get kubeconfig --name dev-cluster > dev.kubeconfig

# Set KUBECONFIG to all files
export KUBECONFIG=prod.kubeconfig:staging.kubeconfig:dev.kubeconfig

# Merge and flatten into single file
kubectl config view --flatten > merged.kubeconfig

# Use merged config
export KUBECONFIG=merged.kubeconfig


kubectl config use-context kind-prod-cluster
kubectl create namespace production

kubectl config use-context kind-staging-cluster
kubectl create namespace staging

kubectl config use-context kind-dev-cluster
kubectl create namespace development


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
kctx kind-prod-cluster
kubectl get pods  # runs in production namespace

kctx kind-staging-cluster
kubectl get pods  # runs in staging namespace

kctx kind-dev-cluster
kubectl get pods  # runs in development namespace

## Cleanup 
kind delete clusters prod-cluster staging-cluster dev-cluster

# Question 3
kind create cluster --name prod-cluster

# let's generate privatekey
cd cka/solutions/05-kubeconfig

create_user() {
    user=$1
    group=$2
    sol_dir="sol03"
    
    mkdir -p $sol_dir

    # Step 1: Generate private key
    echo "[*] Generating private key for $user..."
    openssl genrsa -out $sol_dir/$user.key 2048

    # Step 2: Create Certificate Signing Request (CSR)
    echo "[*] Creating CSR for $user..."
    openssl req -new \
        -key $sol_dir/$user.key \
        -out $sol_dir/$user.csr \
        -subj "/CN=$user/O=$group"
    
    # Step 3: Inspect the CSR
    echo "[*] CSR Details:"
    openssl req -in $sol_dir/$user.csr -text -noout

    # Step 4: Create Kubernetes CertificateSigningRequest resource
    echo "[*] Submitting CSR to Kubernetes..."
    CSR_CONTENT=$(cat $sol_dir/$user.csr | base64 | tr -d '\n')
    cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: $user-csr
spec:
  request: $CSR_CONTENT
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

    # Step 5: Review CSR
    echo "[*] Current CSRs:"
    kubectl get csr
    echo "[*] CSR Details for $user-csr:"
    kubectl describe csr $user-csr

    # Step 6: Approve the CSR
    echo "[*] Approving CSR for $user..."
    kubectl certificate approve $user-csr
    
    echo "[*] Approved CSRs:"
    kubectl get csr $user-csr

    # Step 7: Extract the signed certificate
    echo "[*] Extracting signed certificate..."
    kubectl get csr $user-csr -o jsonpath='{.status.certificate}' | base64 -d > $sol_dir/$user.crt
    
    # Step 8: Verify the certificate
    echo "[*] Certificate Details:"
    openssl x509 -in $sol_dir/$user.crt -text -noout | head -20

    # Step 9: Add credentials to kubeconfig
    echo "[*] Adding $user credentials to kubeconfig..."
    kubectl config set-credentials $user \
        --client-certificate=$sol_dir/$user.crt \
        --client-key=$sol_dir/$user.key \
        --embed-certs=true

    # Step 10: Create a context for this user
    echo "[*] Creating context for $user..."
    CLUSTER=$(kubectl config view --minify -o jsonpath='{.clusters[0].name}')
    kubectl config set-context $user-context \
        --cluster=$CLUSTER \
        --user=$user \
        --namespace=default

    echo "[✓] User $user created successfully!"
    echo "    Credentials: $sol_dir/$user.key, $sol_dir/$user.crt"
    echo "    Context: $user-context"
    echo ""
}

create_user alice developers
create_user bob developer
create_user admin-carol kubeadm:cluster-admins

kubectl create role podviewer --verb=get --verb=list --resource=pod
kubectl create rolebinding podviewer-developer-binding --role=podviewer --group=developers
kubectl create rolebinding podviewer-alice-binding --role=podviewer --user=alice
kubectl create clusterrolebinding admin-clusters-binding --clusterrole=cluster-admin --group=kubeadm:admin-clusters

kubectl auth can-i list pods --as=alice

kubectl config use alice-context

kubectl get po



kubectl config set-credentials alice --client-certificate=sol03/alice.crt --client-key=sol03/alice.key --embed-certs=true
kubectl config set-credentials bob --client-certificate=sol03/bob.crt --client-key=sol03/bob.key --embed-certs=true
kubectl config set-credentials admin-carol --client-certificate=sol03/admin-carol.crt --client-key=sol03/admin-carol.key --embed-certs=true 

## Cleanup Question 3
for node in $(kind get clusters); do
    kind delete cluster --name $node
done

# Question 12
kind create cluster --name dev
kind create cluster --name prod

kubectl config get-contexts

kubectl config use kind-dev
mkdir -p sol12
# creating user named alice in kind-dev
openssl genrsa -out sol12/alice.key 2048
cat sol12/alice.key
openssl req -new -key sol12/alice.key -subj "/CN=alice/O=developers" -out sol12/alice.csr
openssl req -in sol12/alice.csr -text

CSR_CONTENT=$(cat sol12/alice.csr | base64 | tr -d "\n")
echo $CSR_CONTENT
cat <<EOF | kubectl apply -f -
apiVersion: certificates.k8s.io/v1
kind: CertificateSigningRequest
metadata:
  name: alice-csr
spec:
  request: $CSR_CONTENT
  signerName: kubernetes.io/kube-apiserver-client
  expirationSeconds: 31536000
  usages:
  - client auth
EOF

kubectl get csr alice-csr
kubectl certificate approve alice-csr

kubectl get csr alice-csr -o jsonpath='{.status.certificate}'| base64 -d > sol12/alice.crt
openssl x509 -in sol12/alice.crt -text
kubectl config set-credentials alice --client-key=sol12/alice.key --client-certificate=sol12/alice.crt --embed-certs=true

# ===========================================
# Verify certificate and key with CA
# ===========================================

# Step 1: Extract CA from kubeconfig
echo "[*] Extracting CA from kubeconfig..."
kubectl config view --raw -o jsonpath='{.clusters[0].cluster.certificate-authority-data}' | base64 -d > sol12/ca.crt

# Inspect CA
echo "[*] CA Certificate Details:"
openssl x509 -in sol12/ca.crt -noout -subject -issuer -dates

# Step 2: Verify certificate is signed by the CA
echo "[*] Verifying alice certificate against CA..."
openssl verify -CAfile sol12/ca.crt sol12/alice.crt

# Step 3: Verify certificate matches private key (compare modulus)
echo "[*] Verifying certificate and private key match..."
cert_modulus=$(openssl x509 -noout -modulus -in sol12/alice.crt | openssl md5)
key_modulus=$(openssl rsa -noout -modulus -in sol12/alice.key | openssl md5)

echo "Certificate modulus: $cert_modulus"
echo "Private key modulus: $key_modulus"

if [ "$cert_modulus" = "$key_modulus" ]; then
    echo "[✓] Certificate and private key match!"
else
    echo "[✗] MISMATCH: Certificate and key do not match!"
fi

# Step 4: Display certificate details
echo ""
echo "[*] Certificate Subject:"
openssl x509 -in sol12/alice.crt -noout -subject -nameopt RFC2253

echo "[*] Certificate Validity:"
openssl x509 -in sol12/alice.crt -noout -dates

echo "[*] CSR and Certificate Comparison:"
echo "CSR Subject:"
openssl req -in sol12/alice.csr -noout -subject -nameopt RFC2253
echo "Cert Subject:"
openssl x509 -in sol12/alice.crt -noout -subject -nameopt RFC2253 

# Cleanup
for node in $(kind get clusters); do
    kind delete cluster --name $node
done