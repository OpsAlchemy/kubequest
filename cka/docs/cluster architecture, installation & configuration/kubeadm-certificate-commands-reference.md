# Complete kubeadm Certificate Management Command Reference

**File name:** `kubeadm-certificate-commands-reference.md`

## kubeadm certs Command Structure

```bash
kubeadm certs [flags]
kubeadm certs [command]

Available Commands:
  certificate-key  Generate certificate keys
  check-expiration Check certificates expiration for a Kubernetes cluster
  generate-csr     Generate keys and certificate signing requests
  renew            Renew certificates for a Kubernetes cluster
```

## 1. Certificate Expiration Commands

### Check All Certificate Expirations
```bash
# Basic expiration check
kubeadm certs check-expiration

# With verbose output
kubeadm certs check-expiration -v=5

# Output specific certificate only
kubeadm certs check-expiration | grep apiserver

# Check with JSON output format
kubeadm certs check-expiration -o json

# Check with YAML output format
kubeadm certs check-expiration -o yaml
```

### Filter and Process Expiration Data
```bash
# List certificates expiring within 90 days
kubeadm certs check-expiration | awk 'NR>2 && $4 ~ /^[0-9]+d$/ {split($4, days, "d"); if (days[1] <= 90) print $0}'

# Extract only certificate names and expiration dates
kubeadm certs check-expiration | awk 'NR>2 && /^[a-z]/ {print $1, $2, $3, $4, $5}'

# Count certificates by expiration status
kubeadm certs check-expiration | grep -c "d$"  # Count certificates (not CAs)
```

## 2. Certificate Renewal Commands

### Renew All Certificates
```bash
# Renew all certificates at once
kubeadm certs renew all

# Renew with confirmation prompt
kubeadm certs renew all --yes

# Renew with dry-run (show what would be done)
kubeadm certs renew all --dry-run

# Renew with specific kubeconfig directory
kubeadm certs renew all --kubeconfig-dir=/custom/kubeconfig

# Renew with specific certificate directory
kubeadm certs renew all --cert-dir=/custom/pki
```

### Renew Specific Certificates
```bash
# Renew API server certificate
kubeadm certs renew apiserver

# Renew etcd certificates
kubeadm certs renew etcd-server
kubeadm certs renew etcd-peer
kubeadm certs renew etcd-healthcheck-client

# Renew client certificates
kubeadm certs renew apiserver-kubelet-client
kubeadm certs renew apiserver-etcd-client
kubeadm certs renew front-proxy-client

# Renew kubeconfig files
kubeadm certs renew admin.conf
kubeadm certs renew controller-manager.conf
kubeadm certs renew scheduler.conf
kubeadm certs renew super-admin.conf
```

### Renew Certificate Groups
```bash
# Renew all etcd-related certificates
kubeadm certs renew etcd-server etcd-peer etcd-healthcheck-client

# Renew all API server certificates
kubeadm certs renew apiserver apiserver-kubelet-client apiserver-etcd-client

# Renew all kubeconfig files
kubeadm certs renew admin.conf controller-manager.conf scheduler.conf
```

## 3. Certificate Key Generation Commands

### Generate Certificate Encryption Key
```bash
# Generate a new certificate key
kubeadm certs certificate-key

# Generate with specific size (default: 2048)
kubeadm certs certificate-key --size=4096

# Generate and save to file
kubeadm certs certificate-key > /etc/kubernetes/pki/certificate-key.txt

# Use in kubeadm init
kubeadm init --certificate-key $(kubeadm certs certificate-key)
```

### Certificate Key for Cluster Upgrades
```bash
# Generate key for encrypted certificate backup
CERT_KEY=$(kubeadm certs certificate-key)
echo $CERT_KEY

# Use during kubeadm init with certificate key
kubeadm init --upload-certs --certificate-key $CERT_KEY

# Store securely for future use
echo "CERTIFICATE_KEY=$CERT_KEY" >> /root/cluster-secrets.env
chmod 600 /root/cluster-secrets.env
```

## 4. Certificate Signing Request (CSR) Commands

### Generate CSRs for External CA
```bash
# Generate all CSRs
kubeadm certs generate-csr

# Generate CSRs with custom directory
kubeadm certs generate-csr --cert-dir=/etc/kubernetes/pki --kubeconfig-dir=/etc/kubernetes

# Generate CSR for specific certificate
kubeadm certs generate-csr --cert-dir=/etc/kubernetes/pki --certificate=apiserver

# View CSR details
openssl req -in /etc/kubernetes/pki/apiserver.csr -text -noout
```

### CSR Generation Options
```bash
# Generate CSRs with specific configuration
kubeadm certs generate-csr \
  --config=/etc/kubernetes/kubeadm-config.yaml \
  --cert-dir=/custom/pki \
  --kubeconfig-dir=/custom/kubeconfig

# List generated CSRs
find /etc/kubernetes/pki -name "*.csr" | sort

# Check CSR subject
openssl req -in /etc/kubernetes/pki/apiserver.csr -subject -noout
```

## 5. Certificate Inspection and Verification Commands

### Verify Certificate Chain
```bash
# Verify API server certificate against CA
openssl verify -CAfile /etc/kubernetes/pki/ca.crt /etc/kubernetes/pki/apiserver.crt

# Verify etcd certificate chain
openssl verify -CAfile /etc/kubernetes/pki/etcd/ca.crt /etc/kubernetes/pki/etcd/server.crt

# Verify all certificates
for cert in /etc/kubernetes/pki/*.crt; do
  echo "Verifying $(basename $cert)..."
  openssl verify -CAfile /etc/kubernetes/pki/ca.crt "$cert" 2>/dev/null || echo "Failed: $(basename $cert)"
done
```

### Certificate Details Inspection
```bash
# View certificate details
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout

# Check specific fields
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -subject -noout
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -issuer -noout
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -dates -noout
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -serial -noout
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -fingerprint -noout

# Check SANs (Subject Alternative Names)
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A1 "Subject Alternative Name"
```

## 6. Certificate Configuration and Management

### Update Certificate Configuration
```bash
# Update kubeadm config with new certificate SANs
cat > /etc/kubernetes/kubeadm-config.yaml << EOF
apiVersion: kubeadm.k8s.io/v1beta3
kind: ClusterConfiguration
apiServer:
  certSANs:
  - "kubernetes"
  - "kubernetes.default"
  - "kubernetes.default.svc"
  - "kubernetes.default.svc.cluster.local"
  - "172.30.1.2"
  - "my-custom-hostname.example.com"
  - "10.0.0.1"
EOF

# Upload updated configuration
kubeadm init phase upload-config kubeadm --config /etc/kubernetes/kubeadm-config.yaml

# Regenerate certificates with new config
kubeadm init phase certs all --config /etc/kubernetes/kubeadm-config.yaml
```

### Manage Externally Managed Certificates
```bash
# Mark certificates as externally managed
kubeadm init phase upload-config kubeadm \
  --certificate-key="" \
  --upload-certs=false

# Check if certificates are externally managed
kubeadm certs check-expiration | grep "EXTERNALLY MANAGED"

# For externally managed certs, renewal must be done manually
# Place new certificates in /etc/kubernetes/pki/
# Restart affected components
```

## 7. Certificate Backup and Restore Commands

### Backup Certificates
```bash
# Backup all certificates and keys
mkdir -p /backup/kubernetes-$(date +%Y%m%d)
cp -r /etc/kubernetes/pki /backup/kubernetes-$(date +%Y%m%d)/
cp /etc/kubernetes/*.conf /backup/kubernetes-$(date +%Y%m%d)/

# Backup with tar compression
tar -czf /backup/k8s-certs-$(date +%Y%m%d).tar.gz /etc/kubernetes/pki /etc/kubernetes/*.conf

# Backup individual certificates
cp /etc/kubernetes/pki/ca.{crt,key} /backup/
cp /etc/kubernetes/pki/apiserver.{crt,key} /backup/
cp /etc/kubernetes/pki/sa.{pub,key} /backup/
```

### Restore Certificates
```bash
# Stop kubelet
systemctl stop kubelet

# Restore from backup
cp -r /backup/pki/* /etc/kubernetes/pki/
cp /backup/*.conf /etc/kubernetes/

# Set proper permissions
chmod 600 /etc/kubernetes/pki/*.key
chmod 644 /etc/kubernetes/pki/*.crt
chmod 644 /etc/kubernetes/*.conf

# Start kubelet
systemctl start kubelet

# Verify restoration
kubectl get nodes
```

## 8. Certificate Troubleshooting Commands

### Common Certificate Issues and Fixes

#### Issue: Certificate Expired
```bash
# Check which certificates expired
kubeadm certs check-expiration | grep "0d"

# Renew expired certificates
kubeadm certs renew all

# Restart components
systemctl restart kubelet
```

#### Issue: Certificate Mismatch
```bash
# Check certificate SANs
openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A1 "Subject Alternative Name"

# Regenerate with correct SANs
kubeadm init phase certs apiserver --apiserver-cert-extra-sans "new-hostname,new-ip"
```

#### Issue: Unknown Certificate Authority
```bash
# Verify CA certificate
openssl x509 -in /etc/kubernetes/pki/ca.crt -text -noout

# Regenerate CA (WARNING: Destructive!)
# Backup first!
kubeadm init phase certs ca
```

### Certificate Validation Script
```bash
#!/bin/bash
# validate-certificates.sh

echo "=== Kubernetes Certificate Validation ==="
echo ""

# 1. Check expiration
echo "1. Certificate Expiration Status:"
kubeadm certs check-expiration
echo ""

# 2. Verify certificate chain
echo "2. Certificate Chain Validation:"
for cert in /etc/kubernetes/pki/*.crt; do
  if [[ $cert != *"ca.crt" ]]; then
    cert_name=$(basename $cert)
    if openssl verify -CAfile /etc/kubernetes/pki/ca.crt "$cert" >/dev/null 2>&1; then
      echo "✓ $cert_name: Valid"
    else
      echo "✗ $cert_name: Invalid"
    fi
  fi
done
echo ""

# 3. Check file permissions
echo "3. File Permissions Check:"
find /etc/kubernetes/pki -name "*.key" -exec ls -la {} \;
echo ""

# 4. Check kubeconfig certificates
echo "4. Kubeconfig Certificate Status:"
for kubeconfig in /etc/kubernetes/*.conf; do
  echo "Checking $(basename $kubeconfig)..."
  kubectl --kubeconfig=$kubeconfig cluster-info 2>/dev/null && echo "  ✓ Accessible" || echo "  ✗ Inaccessible"
done
```

## 9. Advanced Certificate Operations

### Certificate Rotation Without Downtime
```bash
# For high availability clusters
# 1. Renew certificates on one control plane node
kubeadm certs renew all

# 2. Wait for new certificates to propagate
sleep 30

# 3. Restart kubelet
systemctl restart kubelet

# 4. Verify node is healthy
kubectl get nodes

# 5. Repeat for other control plane nodes
```

### Generate Certificates for New Nodes
```bash
# Generate bootstrap token for new node
kubeadm token create --print-join-command

# The new node will automatically generate certificates
# during kubeadm join process

# Verify new node certificates
ssh new-node "kubeadm certs check-expiration"
```

### Certificate Expiry Monitoring Setup
```bash
# Create monitoring script
cat > /usr/local/bin/monitor-certs.sh << 'EOF'
#!/bin/bash
THRESHOLD_DAYS=30
LOG_FILE="/var/log/k8s-cert-monitor.log"

{
  echo "=== Certificate Monitor Run: $(date) ==="
  kubeadm certs check-expiration
  
  echo ""
  echo "=== Certificates Expiring Soon ==="
  kubeadm certs check-expiration | awk -v threshold=$THRESHOLD_DAYS '
  NR>2 && /^[a-z]/ {
    days_left = $4
    sub(/d/, "", days_left)
    if (days_left + 0 <= threshold) {
      printf "%-30s expires in %3d days\n", $1, days_left
    }
  }'
} >> $LOG_FILE

# Send alert if any certificates expiring soon
if kubeadm certs check-expiration | grep -q "0d\|1d\|7d\|14d\|30d"; then
  mail -s "K8s Certificate Alert" admin@example.com < $LOG_FILE
fi
EOF

chmod +x /usr/local/bin/monitor-certs.sh

# Add to cron
echo "0 8 * * * /usr/local/bin/monitor-certs.sh" >> /etc/crontab
```

## 10. CKA Exam Practice Scenarios

### Scenario 1: Renew Expiring Certificate
```bash
# Task: The apiserver certificate is expiring in 5 days. Renew it.
kubeadm certs renew apiserver
systemctl restart kubelet
kubectl get nodes  # Verify
```

### Scenario 2: Check All Certificates
```bash
# Task: Check expiration of all certificates and save apiserver expiry to file
kubeadm certs check-expiration
kubeadm certs check-expiration | grep apiserver | awk '{print $2, $3, $4, $5}' > /opt/apiserver-expiry.txt
```

### Scenario 3: Generate New Certificate Key
```bash
# Task: Generate a new certificate key for cluster upgrades
kubeadm certs certificate-key
# Save output for later use
```

### Scenario 4: Fix Certificate Error
```bash
# Task: Fix "x509: certificate has expired or is not yet valid" error
kubeadm certs renew all --yes
systemctl restart kubelet
```

This comprehensive reference covers all kubeadm certificate management commands with practical examples, troubleshooting scenarios, and CKA-focused practice exercises.