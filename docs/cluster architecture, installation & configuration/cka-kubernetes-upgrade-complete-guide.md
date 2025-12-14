# Complete Kubernetes Cluster Upgrade Guide for CKA

**File name:** `cka-kubernetes-upgrade-complete-guide.md`

## Overview
This document details the complete process of upgrading a Kubernetes cluster using kubeadm, including control plane and worker node upgrades, with emphasis on concepts relevant to the Certified Kubernetes Administrator (CKA) exam.

## Core Upgrade Principles

### 1. Version Compatibility Rules
- **One minor version at a time**: Upgrade only one minor version at a time (e.g., 1.34.1 → 1.34.2 → 1.34.3)
- **kubeadm first**: Always upgrade kubeadm before upgrading the cluster
- **Control plane first**: Upgrade control plane nodes before worker nodes
- **kubelet manual**: kubelet upgrades must be performed manually on each node

### 2. Upgrade Command Matrix
| Command | Purpose | Usage Location |
|---------|---------|----------------|
| `kubeadm upgrade plan` | Check upgrade availability | Control plane |
| `kubeadm upgrade apply` | Upgrade control plane | Control plane |
| `kubeadm upgrade node` | Upgrade worker node | Worker nodes |
| `kubeadm upgrade diff` | Show manifest differences | Any node |

## Detailed Upgrade Process

### Phase 1: Pre-Upgrade Planning

#### 1.1 Check Current State
```bash
# Check cluster version
kubectl version --short

# Check node versions
kubectl get nodes -o wide

# Check component status
kubectl get cs
```

#### 1.2 Run Upgrade Plan
```bash
kubeadm upgrade plan
```
**Output Analysis for CKA:**
- Identifies available target version (v1.34.3 in example)
- Shows components requiring manual upgrade (kubelet)
- Lists control plane components to be upgraded
- Checks config version compatibility

#### 1.3 Backup Critical Components
```bash
# Backup etcd
ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /tmp/etcd-backup.db

# Backup kubeadm config
kubectl get cm kubeadm-config -n kube-system -o yaml > kubeadm-config-backup.yaml

# Backup certificates
cp -r /etc/kubernetes/pki/ /root/pki-backup/
```

### Phase 2: Control Plane Upgrade

#### 2.1 Upgrade kubeadm (First Step!)
```bash
# Check available versions
apt-cache show kubeadm

# Install specific version
apt-get install kubeadm=1.34.3-1.1

# Verify installation
kubeadm version
```

**Common Mistake (from terminal):**
```bash
# WRONG - Missing package name
apt-get install 1.34.3-1.1

# RIGHT - Include package name
apt-get install kubeadm=1.34.3-1.1
```

#### 2.2 Pull Upgrade Images (Optional but Recommended)
```bash
kubeadm config images pull --kubernetes-version v1.34.3
```

#### 2.3 Apply Control Plane Upgrade
```bash
kubeadm upgrade apply v1.34.3
```

**Upgrade Process Flow (Important for CKA):**
1. **Preflight checks**: Cluster health validation
2. **Image pulling**: Downloads new container images
3. **Component upgrade order**:
   - etcd (with certificate renewal)
   - kube-apiserver (with certificate renewal)
   - kube-controller-manager
   - kube-scheduler
4. **Config updates**: Updates kubeadm-config ConfigMap
5. **kubeconfig updates**: Updates admin.conf and other kubeconfig files
6. **Addon updates**: Updates CoreDNS and kube-proxy if needed

**Certificate Renewal During Upgrade:**
- etcd-server, etcd-peer, etcd-healthcheck-client
- apiserver, apiserver-kubelet-client
- front-proxy-client, apiserver-etcd-client
- controller-manager.conf, scheduler.conf

#### 2.4 Upgrade Control Plane Node Components
```bash
apt-get install kubectl=1.34.3-1.1 kubelet=1.34.3-1.1
```
**Important**: kubelet service automatically restarts after upgrade.

### Phase 3: Worker Node Upgrade

#### 3.1 Drain Worker Node (CKA Critical)
```bash
# From control plane node
kubectl drain node01 --ignore-daemonsets --delete-emptydir-data

# Verify node is cordoned
kubectl get nodes
# node01 should show "SchedulingDisabled"
```

#### 3.2 SSH to Worker Node and Upgrade
```bash
ssh node01

# Upgrade kubeadm first
apt-get install kubeadm=1.34.3-1.1

# Use kubeadm upgrade node (NOT apply!)
kubeadm upgrade node

# Upgrade kubelet and kubectl
apt-get install kubectl=1.34.3-1.1 kubelet=1.34.3-1.1

# Restart kubelet if not auto-restarted
systemctl restart kubelet
```

**Critical Difference for CKA:**
- Control plane: `kubeadm upgrade apply`
- Worker nodes: `kubeadm upgrade node`

#### 3.3 Uncordon Node
```bash
# From control plane node
kubectl uncordon node01
```

## Kubeconfig Management for CKA

### Understanding Kubeconfig Structure
```yaml
apiVersion: v1
kind: Config
clusters:
- name: kubernetes
  cluster:
    server: https://172.30.1.2:6443
    certificate-authority-data: <base64-ca-cert>
contexts:
- name: kubernetes-admin@kubernetes
  context:
    cluster: kubernetes
    user: kubernetes-admin
    namespace: default
current-context: kubernetes-admin@kubernetes
users:
- name: kubernetes-admin
  user:
    client-certificate-data: <base64-client-cert>
    client-key-data: <base64-client-key>
```

### Generating Kubeconfig Files

#### Method 1: Using Existing Certificates
```bash
# Generate kubeconfig for admin
kubeadm init phase kubeconfig admin \
  --kubeconfig-dir=/etc/kubernetes \
  --cert-dir=/etc/kubernetes/pki

# Generate kubeconfig for kubelet
kubeadm init phase kubeconfig kubelet \
  --kubeconfig-dir=/etc/kubernetes \
  --cert-dir=/etc/kubernetes/pki
```

#### Method 2: Manual Kubeconfig Creation
```bash
# Set cluster
kubectl config set-cluster kubernetes \
  --server=https://172.30.1.2:6443 \
  --certificate-authority=/etc/kubernetes/pki/ca.crt \
  --embed-certs=true \
  --kubeconfig=/tmp/new-kubeconfig

# Set credentials
kubectl config set-credentials admin \
  --client-certificate=/etc/kubernetes/pki/admin.crt \
  --client-key=/etc/kubernetes/pki/admin.key \
  --embed-certs=true \
  --kubeconfig=/tmp/new-kubeconfig

# Set context
kubectl config set-context default \
  --cluster=kubernetes \
  --user=admin \
  --kubeconfig=/tmp/new-kubeconfig

# Use context
kubectl config use-context default --kubeconfig=/tmp/new-kubeconfig
```

#### Method 3: Generate Kubeconfig for Service Account
```bash
# Create service account
kubectl create serviceaccount my-user

# Create cluster role binding
kubectl create clusterrolebinding my-user-binding \
  --clusterrole=cluster-admin \
  --serviceaccount=default:my-user

# Get token
SECRET_NAME=$(kubectl get serviceaccount my-user -o jsonpath='{.secrets[0].name}')
TOKEN=$(kubectl get secret $SECRET_NAME -o jsonpath='{.data.token}' | base64 --decode)

# Create kubeconfig with token
kubectl config set-credentials my-user --token=$TOKEN
```

### Kubeconfig Troubleshooting Commands
```bash
# Check current context
kubectl config current-context

# View complete config
kubectl config view

# View raw config (with certificates)
kubectl config view --raw

# Switch contexts
kubectl config use-context my-context

# Rename context
kubectl config rename-context old-name new-name

# Delete context
kubectl config delete-context unwanted-context

# Set namespace for context
kubectl config set-context --current --namespace=kube-system
```

## CKA-Specific Upgrade Scenarios

### Scenario 1: Partial Upgrade Failure
```bash
# If upgrade fails mid-way
# Check component status
kubectl get pods -n kube-system

# Check kubelet logs
journalctl -u kubelet -f

# Manual intervention may be needed
# Restore from backup manifests
cp /etc/kubernetes/tmp/kubeadm-backup-manifests-*/kube-apiserver.yaml \
   /etc/kubernetes/manifests/kube-apiserver.yaml
```

### Scenario 2: Certificate Expiry During Upgrade
```bash
# Check certificate expiry
kubeadm certs check-expiration

# Renew certificates
kubeadm certs renew all

# Restart control plane components
systemctl restart kubelet
```

### Scenario 3: Worker Node Cannot Join After Upgrade
```bash
# Check token validity
kubeadm token list

# Create new token if expired
kubeadm token create

# Get discovery token CA cert hash
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt \
  | openssl rsa -pubin -outform der 2>/dev/null \
  | openssl dgst -sha256 -hex \
  | sed 's/^.* //'

# Generate new join command
kubeadm token create --print-join-command
```

## Important Files and Directories

### Upgrade-Related Directories
```
/etc/kubernetes/
├── manifests/           # Static pod manifests
├── pki/                # Certificates
├── admin.conf          # Admin kubeconfig
└── tmp/
    └── kubeadm-backup-manifests-*/  # Backup manifests during upgrade

/var/lib/kubelet/
├── config.yaml         # Kubelet configuration
└── kubeadm-flags.env   # Kubelet flags
```

### Critical Commands for CKA Exam
```bash
# Drain node (always use --ignore-daemonsets)
kubectl drain <node> --ignore-daemonsets --delete-emptydir-data

# Uncordon node
kubectl uncordon <node>

# Check upgrade plan
kubeadm upgrade plan

# Apply upgrade
kubeadm upgrade apply <version>

# Node upgrade
kubeadm upgrade node

# Certificate management
kubeadm certs renew <cert-name>
kubeadm certs check-expiration

# Token management
kubeadm token create --print-join-command
kubeadm token list
```

## Post-Upgrade Verification Checklist

1. **Node Status**: `kubectl get nodes` - All nodes should be Ready
2. **Pod Status**: `kubectl get pods --all-namespaces` - All pods Running
3. **Component Status**: `kubectl get cs` - All components Healthy
4. **Version Verification**: `kubectl version` - Client and server versions match target
5. **Network Test**: Deploy test pod and verify network connectivity
6. **DNS Test**: Verify CoreDNS resolution
7. **API Access**: Verify kubectl commands work without errors

## Common Exam Pitfalls to Avoid

1. **Upgrading kubelet before control plane** - Wrong order
2. **Using `apply` on worker nodes** - Should use `node` command
3. **Forgetting to drain nodes** - Causes pod disruption
4. **Not ignoring daemonsets during drain** - Can't drain node completely
5. **Missing `--ignore-preflight-errors` when needed** - Upgrade fails on warnings
6. **Not backing up etcd** - No recovery option if upgrade fails
7. **Forgetting to uncordon nodes** - Node remains unschedulable

## Summary Workflow for CKA

1. **Plan**: `kubeadm upgrade plan`
2. **Backup**: etcd and certificates
3. **Upgrade kubeadm**: `apt-get install kubeadm=<version>`
4. **Upgrade control plane**: `kubeadm upgrade apply <version>`
5. **Upgrade control plane components**: kubectl and kubelet
6. **Drain worker node**: `kubectl drain`
7. **Upgrade worker**: `kubeadm upgrade node` + kubelet/kubectl
8. **Uncordon worker**: `kubectl uncordon`
9. **Repeat**: For additional worker nodes
10. **Verify**: Complete cluster functionality

This comprehensive guide covers all aspects of Kubernetes upgrades relevant to the CKA exam, including practical examples from the terminal session and critical thinking points for exam scenarios.