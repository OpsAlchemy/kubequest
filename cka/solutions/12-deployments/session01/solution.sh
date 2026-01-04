
#!/usr/bin/env bash
set -euo pipefail

########################################
# Environment setup
########################################

cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/12-deployments/session01

########################################
# KIND cluster configuration
########################################

cat > kind-config.yaml <<EOF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane

- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "topology.kubernetes.io/zone=zone-a"

- role: worker
  kubeadmConfigPatches:
  - |
    kind: JoinConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "topology.kubernetes.io/zone=zone-b"

- role: worker
EOF

########################################
# Create cluster
########################################

kind create cluster \
  --name deployment-session01 \
  --config kind-config.yaml \
  --image kindest/node:v1.34.0 || true

########################################
# Validate cluster + node labels
########################################

echo "=== Validating cluster nodes and labels ==="
kubectl get nodes -L topology.kubernetes.io/zone

########################################
# Solution 1 - DaemonSet: node-config-writer
########################################

echo "=== Deploying Solution 1: node-config-writer ==="
kubectl create namespace ops || true
kubectl apply -f sol1.yaml

echo "=== Validating Solution 1 ==="
sleep 3
kubectl get daemonset -n ops
kubectl get pods -n ops -o wide
echo "Checking if node.txt was created on worker nodes..."
kubectl exec -n ops $(kubectl get pod -n ops -l app=node-config-writer -o jsonpath='{.items[0].metadata.name}') -- cat /host/node.txt || echo "File check completed"

########################################
# Cleanup - Solution 1
########################################

echo "=== Cleaning up Solution 1 ==="
kubectl delete -f sol1.yaml || true
kubectl delete namespace ops || true

########################################
# Solution 2 - DaemonSet: zone-aware-daemon
########################################

echo "=== Deploying Solution 2: zone-aware-daemon ==="
kubectl create namespace infra || true
kubectl apply -f sol2.yaml

echo "=== Validating Solution 2 ==="
sleep 3
kubectl get daemonset -n infra
kubectl get pods -n infra -o wide
echo "Checking ZONE environment variable..."
kubectl logs -n infra -l app=zone-aware-daemon --tail=5 || echo "Logs check completed"

########################################
# Cleanup - Solution 2
########################################

echo "=== Cleaning up Solution 2 ==="
kubectl delete -f sol2.yaml || true
kubectl delete namespace infra || true

########################################
# Solution 3 - DaemonSet: log-collector
########################################

echo "=== Applying taints to all nodes ==="
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  kubectl taint nodes $node test=true:NoSchedule || true
done

echo "=== Deploying Solution 3: log-collector ==="
kubectl create namespace monitoring || true
kubectl config set-context --current --namespace=monitoring
kubectl apply -f sol3.yaml

echo "=== Validating Solution 3 ==="
sleep 3
kubectl get daemonset -n monitoring
kubectl get pods -n monitoring -o wide
echo "Checking log collection status..."
for pod in $(kubectl get pod -n monitoring -l app=log-collector -o jsonpath='{.items[*].metadata.name}'); do
  echo "Pod: $pod"
  kubectl exec -n monitoring $pod -- tail -3 /var/log/node-metrics.log || echo "Unable to read logs from $pod"
done

########################################
# Cleanup - Solution 3
########################################

echo "=== Cleaning up Solution 3 ==="
kubectl delete -f sol3.yaml || true
kubectl delete namespace monitoring || true

echo "=== Removing taints from all nodes ==="
for node in $(kubectl get nodes -o jsonpath='{.items[*].metadata.name}'); do
  kubectl taint nodes $node test=true:NoSchedule- || true
done

########################################
# Solution 4 - DaemonSet: network-monitor
########################################

echo "=== Deploying Solution 4: network-monitor ==="
kubectl create namespace system || true
kubectl apply -f sol4.yaml

echo "=== Validating Solution 4 ==="
sleep 3
kubectl get daemonset -n system
kubectl get pods -n system -o wide
echo "Checking network information logging..."
for pod in $(kubectl get pod -n system -l app=network-monitor -o jsonpath='{.items[*].metadata.name}'); do
  echo "Pod: $pod"
  kubectl exec -n system $pod -- tail -3 /var/log/network-info.log || echo "Unable to read logs from $pod"
done

########################################
# Cleanup - Solution 4
########################################

echo "=== Cleaning up Solution 4 ==="
kubectl delete -f sol4.yaml || true
kubectl delete namespace system || true

########################################
# Cleanup - Cluster
########################################

echo "=== Cleaning up KIND cluster ==="
kind delete cluster --name deployment-session01 || true













########################################
# Complete cleanup
########################################

kind delete cluster --name deployment-session01

