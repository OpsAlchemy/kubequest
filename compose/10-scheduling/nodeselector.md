# **NodeSelector**

---

## **What is nodeSelector?**

`nodeSelector` is a field in a Pod spec that selects nodes based on their **labels**. Unlike `nodeName` which bypasses the scheduler, `nodeSelector` works **with** the scheduler to match pods to nodes with specific labels.

## **How It Works**

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: example-pod
spec:
  nodeSelector:          # ← This is the key field
    disktype: ssd        # Node must have label disktype=ssd
    region: us-east      # Node must have label region=us-east
  containers:
  - name: main
    image: nginx
```

The scheduler will only place this pod on nodes that have **ALL** the labels specified in `nodeSelector`.

## **Key Differences: nodeSelector vs nodeName**

| Feature | `nodeName` | `nodeSelector` |
|---------|------------|----------------|
| **Scheduler** | Bypasses scheduler | Works with scheduler |
| **Flexibility** | Hardcoded node name | Uses labels (more flexible) |
| **Failover** | No failover | Can reschedule to other matching nodes |
| **Validation** | No resource checking | Normal scheduler validation |
| **Production Use** | Rarely used | Commonly used |

## **Step-by-Step Usage**

### 1. **Label Your Nodes**
```bash
# Add labels to nodes
kubectl label nodes node-01 disktype=ssd
kubectl label nodes node-01 region=us-east

kubectl label nodes node-02 disktype=hdd
kubectl label nodes node-02 region=us-west

# Verify labels
kubectl get nodes --show-labels
```

### 2. **Create Pod with nodeSelector**
```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  nodeSelector:
    disktype: ssd
    region: us-east
  containers:
  - name: app
    image: nginx:alpine
```

### 3. **Verify Scheduling**
```bash
# Check which node the pod landed on
kubectl get pod web-app -o wide

# Describe the pod to see scheduling details
kubectl describe pod web-app
```

## **Common Use Cases**

1. **Hardware Requirements**
```yaml
nodeSelector:
  gpu: "true"
  memory: "high"
```

2. **Environment/Region**
```yaml
nodeSelector:
  environment: production
  zone: zone-a
```

3. **Team/Project Isolation**
```yaml
nodeSelector:
  team: data-science
  project: ml-training
```

## **Limitations**

1. **AND Logic Only**: All labels must match (cannot do OR logic)
2. **No Preferences**: Cannot say "prefer SSD, but HDD is okay" 
3. **No Complex Rules**: Cannot specify "not equal to" or "exists" operators

## **Best Practices**

1. **Use Meaningful Labels**: `disktype:ssd` instead of `type:1`
2. **Document Labels**: Keep a list of node labels your team uses
3. **Combine with Resources**: Use with resource requests/limits
4. **Test Label Matching**: Verify labels exist before deploying

## **Troubleshooting**

**Pod Stays Pending?**
```bash
# Check if any nodes have the required labels
kubectl get nodes -l disktype=ssd,region=us-east

# Check pod events
kubectl describe pod [pod-name]

# Check node capacity
kubectl describe node [node-name]
```

**Remove Labels:**
```bash
kubectl label node node-01 disktype-
```

---

## **Practice Question 2**

You have a Kubernetes cluster with the following nodes and labels:

```
Node: worker-1
  Labels: environment=production, storage=ssd, zone=us-east-1a

Node: worker-2  
  Labels: environment=staging, storage=hdd, zone=us-east-1b

Node: worker-3
  Labels: environment=production, storage=ssd, zone=us-east-1b
```

Create a Pod YAML for a database application that:
1. **Pod name**: `production-db`
2. **Image**: `postgres:14`
3. **Label the pod**: `app: database`
4. **Environment variable**: `POSTGRES_PASSWORD: secret123`
5. **Must run** only on nodes with:
   - `environment=production`
   - `storage=ssd`
6. **Container port**: `5432`

**Write your YAML solution below:**