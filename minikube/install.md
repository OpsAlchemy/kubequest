The issue is that the MetalLB webhook is not ready yet. You have two conflicting MetalLB installations:

1. **Native MetalLB** (from the manifest you applied)
2. **Minikube addon version** (older version)

Let's fix this by cleaning up and using only one approach:

## 1. First, Clean Up Everything

```bash
# Delete the minikube addon version
minikube addons disable metallb

# Delete the native MetalLB installation
kubectl delete -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Wait for cleanup
kubectl delete ns metallb-system --force --grace-period=0
```

## 2. Install Only Native MetalLB (Recommended)

```bash
# Install the latest native MetalLB
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Wait for MetalLB to be fully ready
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=120s

# Check all pods are running
kubectl get pods -n metallb-system
```

## 3. Apply MetalLB Configuration

```bash
# Wait for webhook to be ready (this might take a minute)
sleep 30

# Now apply your configuration
kubectl apply -f metallb.yaml
```

## 4. Or Apply Configuration Directly

```bash
# Apply configuration directly without file
kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 192.168.39.100-192.168.39.150
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF
```

## 5. Verify Installation

```bash
# Check CRDs
kubectl get crd | grep metallb

# Check IPAddressPool
kubectl get ipaddresspool -n metallb-system

# Check L2Advertisement
kubectl get l2advertisement -n metallb-system

# Check all MetalLB resources
kubectl get all -n metallb-system
```

## 6. Test with LoadBalancer

```bash
# Create test service
kubectl create deployment nginx-test --image=nginx
kubectl expose deployment nginx-test --port=80 --type=LoadBalancer

# Watch for external IP
watch kubectl get svc nginx-test
```

The key issue was having **two conflicting MetalLB installations**. The webhook error occurs because the validation webhook wasn't ready yet. By using only the native MetalLB installation (not the minikube addon), it should work correctly! 🎯
