cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/05-kubeconfig

cat > kind-multinode.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
EOF

kind create cluster --name=multi-node-cluster --config=kind-multinode.yaml




# From your local terminal, check cluster status
kubectl get nodes
kubectl get csr

# If node shows Ready, then kubelet is using the correct certificate
# Let's check what certificate kubelet is actually using to talk to API Server

# Check the kubelet-client-current.pem certificate details
echo "Checking the actual certificate kubelet uses:"
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem | openssl x509 -text -noout | head -30

# Check its issuer
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem | openssl x509 -noout -issuer

# This is the actual certificate kubelet uses (from kubelet.conf)
# The kubelet.crt might be an old/backup file


# Check the pem file (contains both cert and key)
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem

# Extract just the certificate part
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -text -noout | head -20

# Check its subject
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem | sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' | openssl x509 -noout -subject -issuer


# Verify the actual certificate against control-plane CA
CONTROL_PLANE_CA=$(docker exec multi-node-cluster-control-plane cat /etc/kubernetes/pki/ca.crt)
docker exec multi-node-cluster-worker cat /var/lib/kubelet/pki/kubelet-client-current.pem | \
  sed -n '/-----BEGIN CERTIFICATE-----/,/-----END CERTIFICATE-----/p' > /tmp/worker-cert.crt

# Write control-plane CA to file
echo "$CONTROL_PLANE_CA" > /tmp/k8s-ca.crt

# Verify
openssl verify -CAfile /tmp/k8s-ca.crt /tmp/worker-cert.crt



# Check what's in the CA cert
cat /etc/kubernetes/pki/ca.crt | openssl x509 -text -noout | head -20

# Check CN of CA
cat /etc/kubernetes/pki/ca.crt | openssl x509 -noout -subject

# Check the kubelet.crt issuer again
cat /var/lib/kubelet/pki/kubelet.crt | openssl x509 -noout -issuer -subject

# The kubelet.crt appears to be self-signed or signed by different CA
# Let's check if this is a bootstrap certificate
ls -la /var/lib/kubelet/pki/

# Check if there's a bootstrap kubeconfig
ls -la /etc/kubernetes/
cat /etc/kubernetes/bootstrap-kubelet.conf 2>/dev/null || echo "No bootstrap config"

# Let's check control-plane CA
docker exec multi-node-cluster-control-plane cat /etc/kubernetes/pki/ca.crt | openssl x509 -noout -subject

# Compare with worker CA
cat /etc/kubernetes/pki/ca.crt | openssl x509 -noout -subject