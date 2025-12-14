# Kubernetes Cluster Initialization and Node Join Process Notes

**File name:** `kubeadm-cluster-init-troubleshooting.md`

## Table of Contents
1. [Cluster Initialization Process](#cluster-initialization-process)
2. [Common Errors and Solutions](#common-errors-and-solutions)
3. [Node Joining Process](#node-joining-process)
4. [Kubectl Configuration Issues](#kubectl-configuration-issues)
5. [Key Takeaways](#key-takeaways)

## Cluster Initialization Process

### Initialization Command Evolution
The process shows iterative refinement of the `kubeadm init` command:

1. **First attempt:**
   ```bash
   kubeadm init --kubernetes-version=1.34.1
   ```
   - **Error:** Failed due to preflight check for CPU count
   - **Diagnosis:** `[ERROR NumCPU]: the number of available CPUs 1 is less than the required 2`

2. **Second attempt with corrections:**
   ```bash
   kubeadm init --kubernetes-version=1.34.1 --pod-network-cidr=192.268.0.0/16 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem
   ```
   - **Error:** Invalid CIDR notation (`192.268.0.0/16` contains invalid octet 268)
   - **Diagnosis:** `error: networking.podSubnet: Invalid value: "192.268.0.0/16": couldn't parse subnet`

3. **Successful initialization:**
   ```bash
   kubeadm init --kubernetes-version=1.34.1 --pod-network-cidr 192.168.0.0/16 --ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem
   ```
   - Fixed CIDR to `192.168.0.0/16`
   - Added proper spacing for `--pod-network-cidr` parameter

### Successful Initialization Output Key Points
- Kubernetes version: v1.34.1
- Control plane components deployed as static pods in `/etc/kubernetes/manifests/`
- Certificates generated in `/etc/kubernetes/pki/`
- Kubeconfig files created in `/etc/kubernetes/`
- CoreDNS and kube-proxy addons applied
- Token generated for node joining: `m3qmx4.qa9c83ju82ru6njq`
- Join command provided with discovery token and CA certificate hash

## Common Errors and Solutions

### Preflight Error Overrides
```bash
--ignore-preflight-errors=NumCPU --ignore-preflight-errors=Mem
```
**When to use:** In development/test environments where minimum hardware requirements aren't met.

**Warning:** Ignoring `Mem` (memory) check should be done cautiously as insufficient memory can cause cluster instability.

### Network CIDR Configuration
**Correct format:** `--pod-network-cidr 192.168.0.0/16`
- CIDR notation must have valid IP ranges (each octet 0-255)
- Required for certain CNI plugins like Calico, Flannel
- Must not conflict with host network or service CIDR

### Kubelet Sandbox Image Warning
```
detected that the sandbox image "registry.k8s.io/pause:3.5" of the container runtime is inconsistent with that used by kubeadm. It is recommended to use "registry.k8s.io/pause:3.10.1"
```
**Action:** This is a warning, not an error. The cluster will function but may have version inconsistencies.

## Node Joining Process

### Worker Node Join Command
```bash
kubeadm join 172.30.1.2:6443 --token m3qmx4.qa9c83ju82ru6njq \
        --discovery-token-ca-cert-hash sha256:4b0e1b1109e852de2f92bbb4bf0bdeae7616dd94ec1a35da21ba7ba83c0bb441
```

### Join Process Observations
1. **Preflight warnings:** Hostname resolution warnings (non-critical)
2. **Configuration loaded:** From ConfigMap `kubeadm-config` in `kube-system` namespace
3. **Kubelet configuration:** Written to `/var/lib/kubelet/`
4. **TLS bootstrap:** Certificate signing request sent to API server

## Kubectl Configuration Issues

### Control Plane Configuration
**Problem after init:**
```bash
k get pods
# Error: connection to the server localhost:8080 was refused
```

**Solution:**
```bash
cp /etc/kubernetes/admin.conf /root/.kube/config
```

**Verification:**
```bash
kubectl version  # Shows both client and server versions
kubectl get pod -A  # Shows all pods across namespaces
```

### Worker Node Configuration Issues
**Problem on worker node:**
```bash
cp /etc/kubernetes/admin.conf /root/.kube/config
# Error: cp: cannot stat '/etc/kubernetes/admin.conf': No such file or directory
```

**Root Cause:** The `admin.conf` file only exists on the control plane node. Worker nodes don't have administrative kubeconfig by default.

**Solution for worker nodes:** One of these approaches:
1. Copy the admin.conf from control plane to worker node:
   ```bash
   # On control plane:
   scp /etc/kubernetes/admin.conf node-summer:/root/.kube/config
   ```
   
2. Use the join token to create a limited kubeconfig:
   ```bash
   # On worker node:
   kubectl config set-cluster kubernetes --server=https://172.30.1.2:6443 --certificate-authority=/etc/kubernetes/pki/ca.crt
   kubectl config set-credentials kubelet --token=m3qmx4.qa9c83ju82ru6njq
   kubectl config set-context default --cluster=kubernetes --user=kubelet
   kubectl config use-context default
   ```

### Important Configuration Paths
| File | Location | Purpose |
|------|----------|---------|
| admin.conf | `/etc/kubernetes/admin.conf` | Administrative kubeconfig (control plane only) |
| kubelet.conf | `/etc/kubernetes/kubelet.conf` | Kubelet kubeconfig |
| Cluster CA | `/etc/kubernetes/pki/ca.crt` | Cluster certificate authority |
| Kubeconfig dir | `$HOME/.kube/config` | User kubeconfig location |

## Key Takeaways

### 1. Preflight Checks Are Important
- Kubeadm validates system requirements before initialization
- Use `--ignore-preflight-errors` judiciously in development
- Production environments should meet all requirements

### 2. Network Configuration Matters
- Pod network CIDR must be correctly formatted
- Must not conflict with existing networks
- Required for CNI plugin compatibility

### 3. Kubeconfig Management
- `admin.conf` is generated only on the control plane
- Must be copied to user's `.kube/config` to use kubectl
- Worker nodes don't receive admin kubeconfig automatically
- Alternative: Use `export KUBECONFIG=/etc/kubernetes/admin.conf`

### 4. Join Process Isolation
- Worker nodes join using token and CA hash
- Join process doesn't configure kubectl for the user
- Additional steps needed for kubectl access on workers

### 5. Post-Initialization Verification
```bash
# Check cluster status
kubectl get nodes
kubectl get pods -A
kubectl get cs  # Component status (deprecated in newer versions)

# Check system pods
kubectl get pods -n kube-system
```

### 6. Next Steps After Successful Initialization
1. Configure pod network (CNI plugin)
2. Join worker nodes
3. Configure storage (if needed)
4. Deploy applications
5. Set up monitoring and logging
6. Configure authentication/authorization (RBAC)

This process demonstrates a typical Kubernetes cluster setup workflow with kubeadm, highlighting common pitfalls and their solutions in a learning environment.