#!/bin/bash
# ------------------------------------------------------------
# Lab 01: Deploy nginx pod on controlplane only
# Problem Statement:
#   - Deploy a pod named "nginxpod" using image "nginx"
#   - Ensure the pod is scheduled on the controlplane node
#   - It must not run on worker nodes
# ------------------------------------------------------------

set -e

# ============================================================
# Solution 1: Taint Manipulation (learning/demo only)
# ------------------------------------------------------------
# Step 1: Remove taint from controlplane
kubectl taint node k8s-master node-role.kubernetes.io/control-plane:NoSchedule-

# Step 2: Add taint to workers
kubectl taint node k8s-worker worker=NoSchedule

# Step 3: Deploy pod
kubectl apply -f manifest.yaml --record

# Verify pod scheduled on controlplane
kubectl get pods -o wide | grep nginxpod-taint

# ============================================================
# Solution 2: Direct nodeName Assignment (preferred for exam)
# ------------------------------------------------------------
# This works without touching taints
kubectl apply -f manifest.yaml --record

# Verify pod scheduled on controlplane
kubectl get pods -o wide | grep nginxpod-nodename

# ============================================================
# Cleanup
# ------------------------------------------------------------
# Delete all pods created in this lab
kubectl delete -f manifest.yaml








kubectl top nodes --sort-by=memory | awk 'NR==2 {print c","$1}' c=$(kubectl config current-context) > /root/high_memory_node.txt
awk 'NR==2 {print $2 "," $1}'



kubectl run dnsutils -it --rm --restart=Never --image=busybox:1.36 -- nslookup kubernetes.default


cat <<'EOF' | kubectl apply -n dns-ns -f -
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: dns-rs-cka
spec:
  replicas: 2
  selector:
    matchLabels:
      run: dns-rs-cka
  template:
    metadata:
      labels:
        run: dns-rs-cka
    spec:
      containers:
      - name: dns-container
        image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
        command: ["sleep", "3600"]
EOF

# Wait for pods to be ready
kubectl wait -n dns-ns --for=condition=Ready pod -l run=dns-rs-cka --timeout=120s





# Set context
kubectl config use-context kubernetes-admin@kubernetes

# Namespace
kubectl create namespace dns-ns

# Deployment with 2 replicas, custom container name, and sleep command
cat <<'EOF' | kubectl apply -n dns-ns -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: dns-deploy-cka
spec:
  replicas: 2
  selector:
    matchLabels:
      app: dns-deploy-cka
  template:
    metadata:
      labels:
        app: dns-deploy-cka
    spec:
      containers:
      - name: dns-container
        image: registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3
        command: ["sleep","3600"]
EOF

# Wait for pods to be ready
kubectl wait -n dns-ns --for=condition=Available deployment/dns-deploy-cka --timeout=120s

# Run nslookup from one pod and save output
POD=$(kubectl get pod -n dns-ns -l app=dns-deploy-cka -o jsonpath='{.items[0].metadata.name}')
kubectl exec -n dns-ns "$POD" -- nslookup kubernetes.default | tee dns-output.txt
