# **Kubernetes Scheduling: Pod & Node Affinity - Theory & Practice**

---

## **1. Theoretical Foundation: How Affinity Works**

### **Key Concepts:**
- **Labels**: Key-value pairs attached to Kubernetes objects (nodes, pods)
- **Node Affinity**: Rules based on **NODE LABELS**
- **Pod Affinity**: Rules based on **EXISTING POD LABELS**

### **Node Affinity Operators Explained:**

| Operator | What It Does | Example | When to Use |
|----------|--------------|---------|-------------|
| `In` | Value must be in list | `zone` in ["us-east-1a", "us-east-1b"] | Specific values allowed |
| `NotIn` | Value must NOT be in list | `node-type` not in ["spot", "preemptible"] | Exclude certain node types |
| `Exists` | Label key must exist | `gpu` exists | Check for feature presence |
| `DoesNotExist` | Label key must NOT exist | `maintenance` does not exist | Avoid problematic nodes |
| `Gt`, `Lt` | Numeric comparison | `memory-gb` > 16 | Resource-based selection |

### **Important Theory Points:**

1. **NodeSelectorTerms Logic**:
   - **Within a term**: All conditions must be true (AND logic)
   - **Between terms**: Any term can be true (OR logic)
   
2. **Required vs Preferred**:
   - `requiredDuringScheduling`: MUST be satisfied (hard rule)
   - `preferredDuringScheduling`: SHOULD be satisfied (soft rule, weighted 1-100)

3. `IgnoredDuringExecution`: Once scheduled, rules aren't re-evaluated if labels change

---

## **2. Pod Affinity Theory: Relationships Between Pods**

### **Three Types of Pod Relationships:**
1. **Pod Affinity**: "Run near these pods" (attraction)
2. **Pod Anti-Affinity**: "Don't run near these pods" (repulsion)
3. **Topology**: Defines what "near" means

### **Topology Keys Theory:**
A topology key is a **node label** that defines a grouping domain:

- **`kubernetes.io/hostname`** = Different physical/virtual machines
- **`topology.kubernetes.io/zone`** = Different availability zones
- **`topology.kubernetes.io/region`** = Different geographic regions
- **Custom keys** = Your own grouping logic (e.g., `rack`, `row`, `datacenter`)

### **How Pod Affinity Works:**
```yaml
podAntiAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
  - labelSelector:
      matchLabels:
        app: web  # Look for pods with this label
    topologyKey: kubernetes.io/hostname  # Group by node
```
**Translation**: "Don't schedule this pod on any node that already has a pod with label `app=web`"

---

## **3. Complete Practical Example with Theory Applied**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: example-app
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: example
        tier: backend
    spec:
      affinity:
        # NODE AFFINITY: Where can pods go?
        nodeAffinity:
          # HARD REQUIREMENT: Must be satisfied
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            # Term 1: Production environment
            - matchExpressions:
              - key: environment
                operator: In
                values: ["production"]
              - key: available
                operator: Exists
            # Term 2: OR staging with SSD
            - matchExpressions:
              - key: environment
                operator: In
                values: ["staging"]
              - key: storage-type
                operator: In
                values: ["ssd"]
          
          # SOFT PREFERENCE: Try to satisfy
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 90  # Higher weight = more important
            preference:
              matchExpressions:
              - key: zone
                operator: In
                values: ["us-east-1a"]
        
        # POD ANTI-AFFINITY: How pods relate to each other
        podAntiAffinity:
          # HARD: Don't put pods on same node
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchLabels:
                app: example  # Look for our own pods
            topologyKey: kubernetes.io/hostname  # Different nodes
          
          # SOFT: Try to spread across zones
          preferredDuringSchedulingIgnoredDuringExecution:
          - weight: 70
            podAffinityTerm:
              labelSelector:
                matchLabels:
                  app: example
              topologyKey: topology.kubernetes.io/zone  # Different zones
      
      containers:
      - name: app
        image: nginx
```

**Theory Applied:**
1. **Node Selection**: Pods can run in production (any storage) OR staging (only SSD)
2. **Preference**: Prefer zone us-east-1a if possible
3. **Pod Placement**: Never on same node, try for different zones
4. **Result**: High availability across failure domains

---

## **4. When to Use Each Feature - Decision Guide**

### **Use Node Affinity When:**
- Pod needs specific hardware (GPU, SSD, memory)
- Pod needs to run in specific region/zone
- You want to dedicate nodes to certain workloads
- You need to exclude certain node types

### **Use Pod Affinity When:**
- Related pods should be co-located (app + cache)
- You need data locality (pod near its data)
- Communication latency matters

### **Use Pod Anti-Affinity When:**
- You need high availability (spread across nodes/zones)
- You want to avoid resource contention
- You have stateful applications that shouldn't share nodes

### **Use Topology Spread Constraints (Alternative):**
- For simpler "spread evenly" requirements
- When you want built-in balancing
- For zone/region spreading without complex rules

---

## **5. Practice Questions**

### **Question 1: Basic Node Affinity**
Create a Deployment that:
1. Name: `cache-app`
2. Replicas: 2
3. Image: `redis:alpine`
4. Must run on nodes with label `memory-type=high`
5. Should prefer nodes with label `storage=ssd` (weight: 80)
6. Pods should not be on the same node

### **Question 2: Complex Node Selection**
Create a StatefulSet that:
1. Name: `postgres-cluster`
2. Replicas: 3
3. Image: `postgres:15`
4. Requirements:
   - Must be in production environment
   - Must have fast storage (any label with "fast" in key)
   - Must NOT be on spot instances
   - Must NOT be under maintenance
5. Each pod should have 10Gi persistent storage

### **Question 3: Pod Anti-Affinity for HA**
Create a Deployment that:
1. Name: `web-frontend`
2. Replicas: 5
3. Image: `nginx:latest`
4. Requirements:
   - Hard rule: Pods must be on different nodes
   - Soft rule: Try to spread across zones (weight: 100)
   - Pods should prefer to run near cache pods (weight: 60)
5. Add readiness and liveness probes

### **Question 4: Complete Production Setup**
Create a complete application with:
1. Deployment: `api-server` (3 replicas)
2. Deployment: `redis-cache` (2 replicas)
3. Requirements:
   - Both must run in `environment=production`
   - API pods should be on same nodes as cache pods
   - API pods should be spread across zones
   - Cache pods should be on different nodes
   - Prefer nodes with label `instance-type=large`
4. Include all necessary: resources, probes, environment variables