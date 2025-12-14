# Kubernetes Pod Affinity: Advanced Guide

## Core Concepts Deep Dive

### Pod Affinity Fundamentals
Pod Affinity/Anti-affinity are scheduling constraints that allow you to:
- Attract Pods to nodes with certain Pods (Affinity)
- Repel Pods from nodes with certain Pods (Anti-affinity)
- Control co-location or separation of workloads

## Topology Key Explained

### What is Topology Key?
Topology Key defines how "closeness" is measured between Pods. It's a node label that defines a topology domain - a group of nodes that share common characteristics.

### Common Topology Keys

**1. Node-Level Topology**
```
kubernetes.io/hostname
```
- Most granular level
- Pods must be on the exact same node
- Use case: Pods that need IPC, shared memory, or local volume access

**2. Zone-Level Topology**
```
topology.kubernetes.io/zone
```
- Groups nodes by availability zone
- Common in cloud providers (AWS Availability Zones, GCP Zones, Azure Availability Zones)
- Use case: High availability across failure domains

**3. Region-Level Topology**
```
topology.kubernetes.io/region
```
- Groups nodes by geographic region
- Larger failure domain than zones
- Use case: Disaster recovery, geographic distribution

**4. Custom Topology Keys**
You can define custom labels on nodes:
```
node-group: gpu-nodes
rack: rack-1
datacenter: dc-east
```

## Advanced Pod Affinity Types

### 1. Required During Scheduling (Hard Requirements)
```yaml
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: database
      topologyKey: topology.kubernetes.io/zone
```
- MUST be satisfied for scheduling
- If no matching node exists, Pod remains Pending
- Use for critical constraints (e.g., "must be in same zone as database")

### 2. Preferred During Scheduling (Soft Preferences)
```yaml
affinity:
  podAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 80
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: cache
        topologyKey: kubernetes.io/hostname
    - weight: 20
      podAffinityTerm:
        labelSelector:
          matchLabels:
            env: production
        topologyKey: topology.kubernetes.io/zone
```
- Weighted preferences (1-100)
- Scheduler tries to satisfy but can schedule elsewhere
- Multiple preferences with different weights

### 3. Pod Anti-Affinity
```yaml
affinity:
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: web-server
      topologyKey: kubernetes.io/hostname
```
- Avoid scheduling with matching Pods
- Critical for high availability (spread Pods across nodes/zones)

## Real-World Use Cases

### Use Case 1: Database and Application Pods
```yaml
# Application Pod - Must be in same zone as database
apiVersion: v1
kind: Pod
metadata:
  name: app-server
spec:
  affinity:
    podAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
      - labelSelector:
          matchLabels:
            component: mysql-primary
        topologyKey: topology.kubernetes.io/zone
```

### Use Case 2: High Availability Web Servers
```yaml
# Web Server Pod - Must NOT be on same node as other web servers
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-deployment
spec:
  replicas: 3
  template:
    spec:
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: web-server
            topologyKey: kubernetes.io/hostname
```

### Use Case 3: Cache Co-location with Weighted Preferences
```yaml
# Cache Client Pod - Prefer same node, settle for same zone
apiVersion: v1
kind: Pod
metadata:
  name: cache-client
spec:
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: redis-cache
          topologyKey: kubernetes.io/hostname
      - weight: 50
        podAffinityTerm:
          labelSelector:
            matchLabels:
              app: redis-cache
          topologyKey: topology.kubernetes.io/zone
```

## Multi-Topology Affinity

### Combined Constraints
```yaml
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          tier: backend
      topologyKey: topology.kubernetes.io/zone
  podAntiAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - weight: 100
      podAffinityTerm:
        labelSelector:
          matchLabels:
            app: frontend
        topologyKey: kubernetes.io/hostname
```
- Must be in same zone as backend
- Prefer not to be on same node as frontend

## Namespace Considerations

### Cross-Namespace Affinity
```yaml
affinity:
  podAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
    - labelSelector:
        matchLabels:
          app: shared-service
      topologyKey: kubernetes.io/hostname
      namespaces:
        - shared-services
        - default
      namespaceSelector:
        matchLabels:
          env: production
```
- `namespaces`: List of specific namespaces
- `namespaceSelector`: Select namespaces by labels
- If both omitted, defaults to Pod's namespace

## Weight and Scoring Details

### How Weights Work
```
Final Score = Σ(weight_of_satisfied_term)
```
- Weights are 1-100
- Higher weight = stronger preference
- Scheduler calculates score for each node
- Node with highest score is selected

### Example Scoring
```yaml
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 60  # Priority 1
  podAffinityTerm: { ... }
- weight: 30  # Priority 2
  podAffinityTerm: { ... }
- weight: 10  # Priority 3
  podAffinityTerm: { ... }
```

## Node Affinity vs Pod Affinity

### Key Differences
| Aspect | Node Affinity | Pod Affinity |
|--------|--------------|--------------|
| Based on | Node labels | Pod labels |
| Use case | Hardware/Zone requirements | Workload co-location |
| Scope | Single Pod scheduling | Inter-Pod relationships |
| Topology | Node characteristics | Pod distribution |

### Combined Usage
```yaml
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: gpu-type
          operator: In
          values: [nvidia-tesla-v100]
  podAffinity:
    preferredDuringSchedulingIgnoredDuringExecution:
    - podAffinityTerm:
        labelSelector:
          matchLabels:
            app: gpu-intensive
        topologyKey: kubernetes.io/hostname
```

## Advanced Match Expressions

### Complex Label Selectors
```yaml
labelSelector:
  matchExpressions:
  - key: app
    operator: In
    values: [frontend, backend]
  - key: version
    operator: NotIn
    values: [deprecated, beta]
  - key: environment
    operator: Exists
  - key: temporary
    operator: DoesNotExist
```

### Operators Available
1. `In`: Label value in set
2. `NotIn`: Label value not in set
3. `Exists`: Label key exists (value doesn't matter)
4. `DoesNotExist`: Label key doesn't exist

## Performance Considerations

### Scheduling Performance Impact
- Complex affinity rules increase scheduler computation time
- Anti-affinity with large clusters can be expensive
- Recommendations:
  - Use `preferred` over `required` when possible
  - Limit scope with namespace selectors
  - Consider pod density on nodes

### Resource Optimization
```yaml
# Efficient: Limited scope
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        app: critical-app
    topologyKey: kubernetes.io/hostname
    namespaces: ["production"]

# Inefficient: Broad scope
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchExpressions:
      - key: app
        operator: Exists
    topologyKey: kubernetes.io/hostname
```

## Troubleshooting Common Issues

### 1. Pod Stuck in Pending
```bash
# Check events
kubectl describe pod <pod-name>

# Check affinity rules
kubectl get pod <pod-name> -o yaml | grep -A 20 affinity

# Check node labels
kubectl get nodes --show-labels

# Check existing pods with required labels
kubectl get pods --all-namespaces -l <label-selector>
```

### 2. Validate Topology Keys
```bash
# List all topology-related labels on nodes
kubectl get nodes -o json | \
  jq '.items[].metadata.labels | with_entries(select(.key | contains("topology")))'
```

### 3. Check Scheduler Logs
```bash
# View scheduler decisions
kubectl logs -n kube-system <scheduler-pod> | grep -i affinity
```

## Best Practices

### 1. Start with Preferred Rules
```yaml
# Start with soft constraints
preferredDuringSchedulingIgnoredDuringExecution:
- weight: 100
  podAffinityTerm: { ... }

# Only move to required if absolutely necessary
requiredDuringSchedulingIgnoredDuringExecution: [ ... ]
```

### 2. Use Appropriate Topology Levels
```
Same node (hostname)     -> Low latency requirements
Same zone                -> High availability
Same region              -> Disaster recovery
Custom topology          -> Special hardware/network
```

### 3. Combine with Resource Requests
```yaml
spec:
  containers:
  - name: app
    resources:
      requests:
        memory: "256Mi"
        cpu: "250m"
      limits:
        memory: "512Mi"
        cpu: "500m"
  affinity:
    podAffinity: { ... }
```

### 4. Document Affinity Rules
```yaml
metadata:
  annotations:
    scheduling.affinity/purpose: "Co-locate with cache for low latency"
    scheduling.affinity/business-impact: "High - affects user experience"
```

## Practical Example Revisited

### Original Problem Solution Enhanced
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    level: hobby
    component: web
  name: hobby-project
  annotations:
    scheduling.notes: "Prefer nodes with restricted pods for security compliance"
spec:
  containers:
  - image: nginx:alpine
    name: web-container
    resources:
      requests:
        cpu: 100m
        memory: 128Mi
  # Primary: Prefer same node as restricted pods
  # Fallback: Accept same zone if needed
  affinity:
    podAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: level
              operator: In
              values: [restricted]
            - key: security-approved
              operator: Exists
          topologyKey: kubernetes.io/hostname
      - weight: 50
        podAffinityTerm:
          labelSelector:
            matchLabels:
              level: restricted
          topologyKey: topology.kubernetes.io/zone
    # Ensure we don't overload any single node
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 30
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: level
              operator: In
              values: [hobby]
          topologyKey: kubernetes.io/hostname
```

This comprehensive guide covers everything from basic concepts to advanced implementations of Pod Affinity in Kubernetes, providing a solid foundation for designing complex scheduling requirements in production environments.