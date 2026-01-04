# NodeName

---

## **Notes on `nodeName`**

**What it does:**
- Forces pod to specific node by name
- Skips normal scheduler logic
- Direct assignment only

**Example:**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  nodeName: target-node-1
  containers:
  - name: main
    image: nginx
```

**Use cases:**
- Hardware-specific nodes
- Local storage access
- Testing purposes

**Limitations:**
- No failover if node fails
- Pod stays Pending if node missing
- No resource validation

**Check placement:**
```bash
kubectl get pod node-monitor -o wide
```

---

## **Question**

You have a 3-node Kubernetes cluster:
- `control-plane`
- `node-01`
- `node-02`

You need to deploy a monitoring pod that **must** run on `node-01` because it has special monitoring tools installed.

Write a Pod YAML manifest that:
1. Pod name: `node-monitor`
2. Image: `ubuntu:latest`
3. Command: `["sleep", "infinity"]`
4. Label: `monitor: system`
5. Force to node: `node-01`