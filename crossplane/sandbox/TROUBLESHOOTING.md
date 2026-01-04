# Kind Cluster Troubleshooting Guide

## Quick Diagnosis

Run this to check your cluster:

```bash
# Is the cluster running?
kind get clusters
docker ps | grep crossplane

# Can you reach the API server?
kubectl cluster-info --request-timeout=30s

# If that times out, wait for API server to boot
sleep 60
kubectl cluster-info --request-timeout=60s

# Check nodes
kubectl get nodes -o wide
```

---

## Problems & Solutions

### Problem 1: Worker Node Cannot Join Cluster

**Symptoms:**
```
failed to join node with kubeadm: command "docker exec --privileged crossplane-worker kubeadm join ..." failed
Context deadline exceeded (Client.Timeout exceeded while awaiting headers)
```

The worker node times out trying to reach the control plane API server at `https://crossplane-control-plane:6443`.

---

### Problem 2: TLS Handshake Timeout (Even Single-Node)

**Symptoms:**
```
E0104 15:34:56.179543 memcache.go:265] "couldn't get current server API group list: 
Get \"https://127.0.0.1:37257/api?timeout=32s\": net/http: TLS handshake timeout"
```

The cluster is created but kubectl can't connect. The API server is slow or unreachable.

---

## Root Causes & Solutions

### Issue 2a: TLS Handshake Timeout (API Server Too Slow)

The API server in kind takes a long time to boot in WSL. It's running but just slow.

**Quick Fix - Wait longer:**
```bash
# Wait 60+ seconds for API server to fully boot
sleep 60

# Then test connectivity
kubectl cluster-info --request-timeout=60s
kubectl get nodes
```

**Permanent Fix - Increase kubelet startup timeout:**
```bash
# Rebuild cluster with more generous timeouts
kind delete cluster --name crossplane

cat > kind-single-node.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-status-update-frequency: "5s"
        node-monitor-grace-period: "40s"
EOF

kind create cluster \
  --name=crossplane \
  --config=kind-single-node.yaml \
  --image kindest/node:v1.34.0

# Wait 2 minutes for full startup
echo "Waiting for API server to boot (this takes ~2 min in WSL)..."
for i in {1..24}; do
  kubectl cluster-info --request-timeout=10s && break
  echo "Attempt $i/24... waiting 5 seconds"
  sleep 5
done

# Verify it's healthy
kubectl get nodes
```

### Issue 2b: WSL Networking Issues (Most Common for Multi-Node)

WSL has networking quirks when Docker containers try to communicate internally. The control plane binds to `127.0.0.1` instead of the container's actual IP.

**Fix for multi-node clusters:**
```bash
# In WSL, modify docker daemon configuration
sudo mkdir -p /etc/docker
sudo tee /etc/docker/daemon.json > /dev/null <<'EOF'
{
  "debug": false,
  "log-driver": "json-file",
  "bridge": "none"
}
EOF

sudo systemctl restart docker
```

### 2. **Network Policy / Reverse Path Filter**

The system's reverse path filter blocks traffic between containers.

**Fix:**
```bash
sudo sysctl -w net.ipv4.conf.all.rp_filter=0
sudo sysctl -w net.ipv4.conf.default.rp_filter=0

# Make permanent
sudo tee /etc/sysctl.d/99-rpfilter.conf > /dev/null <<'EOF'
net.ipv4.conf.all.rp_filter=0
net.ipv4.conf.default.rp_filter=0
EOF

sudo sysctl --system
```

### 3. **Docker Network Mode in WSL**

WSL's VirtioProxy mode can cause issues. Use NAT mode explicitly:

**Fix:**
```bash
# In Windows (PowerShell as Admin)
# Edit C:\Users\<YourUser>\.wslconfig:
[wsl2]
networkingMode=nat
dnsTunnel=false
firewall=false
```

### 4. **DNS Resolution Issues**

Worker node can't resolve `crossplane-control-plane` hostname.

**Verify:**
```bash
docker exec crossplane-worker bash -c 'getent hosts crossplane-control-plane'
```

**If empty, restart docker:**
```bash
sudo systemctl restart docker
```

### 5. **API Server Not Ready**

The control plane API server is still booting.

**Check:**
```bash
docker exec crossplane-control-plane bash -c 'curl -sk https://127.0.0.1:6443/healthz'
```

**Wait if output is empty** — the API server needs more time to start.

---

## Full Workaround Steps

If the above doesn't work, use a single-node cluster instead:

```bash
# Delete problematic cluster
kind delete cluster --name crossplane || true

# Create single-node cluster (more stable in WSL)
cat > kind-single-node.yaml <<'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
EOF

kind create cluster \
  --name crossplane \
  --config kind-single-node.yaml \
  --image kindest/node:v1.34.0

# Verify
kubectl cluster-info --context kind-crossplane
```

---

## Debug Commands

```bash
# Check if cluster exists and is running
kind get clusters
docker ps | grep crossplane

# Check control plane health from inside the container
docker exec crossplane-control-plane bash -c \
  'curl -sk https://127.0.0.1:6443/healthz'

# Check what port the API server is actually on
docker inspect crossplane-control-plane | grep -A 20 "PortBindings"

# Try connecting with increased timeout
export KUBECONFIG=~/.kube/config
kubectl cluster-info --request-timeout=60s

# Check logs from the API server (very slow to boot in WSL)
docker logs crossplane-control-plane | tail -50

# Check if DNS works
docker exec crossplane-control-plane bash -c \
  'nslookup kubernetes.default.svc.cluster.local'

# Look for TLS certificate issues
docker exec crossplane-control-plane bash -c \
  'ls -la /etc/kubernetes/pki/ && openssl x509 -in /etc/kubernetes/pki/apiserver.crt -text -noout | grep -A 5 "Subject:"'

# Check container networking
docker network ls
docker network inspect kind

# Check if the API server process is running
docker exec crossplane-control-plane bash -c \
  'ps aux | grep kube-apiserver'
```

---

## Prevention: Kind with Explicit Network Config

Create a more robust cluster config:

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "0.0.0.0"
  apiServerPort: 6443
  podSubnet: "10.244.0.0/16"
  serviceSubnet: "10.96.0.0/12"
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
- role: worker
```

---

## When All Else Fails

Use **Minikube** instead of Kind:

```bash
# Minikube is more stable in WSL
minikube start --driver=docker --cpus=4 --memory=4096
```
