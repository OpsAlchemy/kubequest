# **Pod Creation Flow in Deployment - Every Step**

## **Phase 1: User Creates Deployment**

### **Step 1: User Command**
```bash
kubectl apply -f deployment.yaml
# or
kubectl create deployment nginx --image=nginx --replicas=3
```

### **Step 2: kubectl → API Server**
```bash
# kubectl sends HTTP request
POST /apis/apps/v1/namespaces/default/deployments
Content-Type: application/json
Authorization: Bearer <token>

{
  "apiVersion": "apps/v1",
  "kind": "Deployment",
  "metadata": {
    "name": "nginx",
    "namespace": "default"
  },
  "spec": {
    "replicas": 3,
    "selector": {
      "matchLabels": {"app": "nginx"}
    },
    "template": {
      "metadata": {
        "labels": {"app": "nginx"}
      },
      "spec": {
        "containers": [{
          "name": "nginx",
          "image": "nginx:latest"
        }]
      }
    }
  }
}
```

## **Phase 2: API Server Processing**

### **Step 3: API Server Validation**
```bash
1. Authentication: Verify kubectl certificate/token
2. Authorization: Check if user can create deployments
3. Admission Control:
   - MutatingWebhook (if any): Modify the object
   - ValidatingWebhook (if any): Validate the object
   - Defaulting: Set default values
```

### **Step 4: Store in etcd**
```bash
API Server → etcd:
PUT /registry/deployments/default/nginx
{
  "deployment object"
}

# Returns: HTTP 201 Created
```

## **Phase 3: Deployment Controller Actions**

### **Step 5: Deployment Controller Watches**
```bash
# Deployment Controller (in controller-manager) is watching:
WATCH /apis/apps/v1/deployments?watch=true

# Event received:
{
  "type": "ADDED",
  "object": {deployment spec}
}
```

### **Step 6: Create ReplicaSet**
```bash
# Deployment Controller creates ReplicaSet
1. Generates ReplicaSet name: nginx-<hash>
2. Sets ownerReference to Deployment
3. Sets replicas = 3
4. Copies pod template from Deployment

POST /apis/apps/v1/namespaces/default/replicasets
{
  "apiVersion": "apps/v1",
  "kind": "ReplicaSet",
  "metadata": {
    "name": "nginx-68bcd98f5c",
    "ownerReferences": [{
      "apiVersion": "apps/v1",
      "kind": "Deployment",
      "name": "nginx",
      "uid": "deployment-uid"
    }]
  },
  "spec": {
    "replicas": 3,
    "selector": {"matchLabels": {"app": "nginx"}},
    "template": {pod template}
  }
}
```

### **Step 7: ReplicaSet Controller Watches**
```bash
# ReplicaSet Controller (in controller-manager) watches:
WATCH /apis/apps/v1/replicasets?watch=true

# Event received:
{
  "type": "ADDED", 
  "object": {replicaset spec with replicas=3}
}
```

### **Step 8: Create Pods**
```bash
# For each replica (i=0,1,2):
1. Generate Pod name: nginx-68bcd98f5c-<random>
2. Set ownerReference to ReplicaSet
3. Copy pod spec from ReplicaSet template
4. Add default fields:
   - restartPolicy: Always
   - terminationGracePeriodSeconds: 30
   - dnsPolicy: ClusterFirst
   - schedulerName: default-scheduler

POST /api/v1/namespaces/default/pods
{
  "apiVersion": "v1",
  "kind": "Pod",
  "metadata": {
    "name": "nginx-68bcd98f5c-abc12",
    "ownerReferences": [{
      "apiVersion": "apps/v1",
      "kind": "ReplicaSet", 
      "name": "nginx-68bcd98f5c",
      "uid": "replicaset-uid"
    }],
    "labels": {"app": "nginx", "pod-template-hash": "68bcd98f5c"}
  },
  "spec": {
    "containers": [...],
    "nodeName": "",  # Empty = unscheduled
  }
}
```

## **Phase 4: Scheduler Actions**

### **Step 9: Scheduler Watches**
```bash
# Scheduler watches for pods with empty nodeName:
WATCH /api/v1/pods?fieldSelector=spec.nodeName=

# Event received:
{
  "type": "ADDED",
  "object": {pod with nodeName=""}
}
```

### **Step 10: Scheduling Decision**
```bash
# Scheduler runs scheduling algorithm:
1. Filter nodes: Check resource requests, node selector, taints/tolerations
2. Score nodes: Calculate best node (bin packing, affinity, etc.)
3. Select node: Choose highest scoring node (e.g., worker-node-1)
```

### **Step 11: Bind Pod to Node**
```bash
# Scheduler updates pod binding:
PATCH /api/v1/namespaces/default/pods/nginx-68bcd98f5c-abc12/binding
{
  "apiVersion": "v1",
  "kind": "Binding",
  "metadata": {"name": "nginx-68bcd98f5c-abc12"},
  "target": {
    "apiVersion": "v1",
    "kind": "Node",
    "name": "worker-node-1"
  }
}
```

### **Step 12: API Server Updates Pod**
```bash
# API Server updates pod:
PATCH /api/v1/namespaces/default/pods/nginx-68bcd98f5c-abc12
{
  "spec": {
    "nodeName": "worker-node-1"
  }
}
```

## **Phase 5: Kubelet Actions**

### **Step 13: Kubelet Watches**
```bash
# Kubelet on worker-node-1 watches:
WATCH /api/v1/pods?fieldSelector=spec.nodeName=worker-node-1

# Event received:
{
  "type": "ADDED",
  "object": {pod with nodeName=worker-node-1}
}
```

### **Step 14: Pod Sync**
```bash
# Kubelet's SyncPod() called:
1. Create pod sandbox (pause container)
2. Pull images (if not present)
3. Create containers via CRI (Container Runtime Interface)
4. Setup volumes (mount PVCs, secrets, configmaps)
5. Setup network (CNI plugin)
6. Start containers
```

### **Step 15: Update Pod Status**
```bash
# Kubelet → API Server:
PATCH /api/v1/namespaces/default/pods/nginx-68bcd98f5c-abc12/status
{
  "status": {
    "phase": "Running",
    "conditions": [
      {"type": "Initialized", "status": "True"},
      {"type": "Ready", "status": "True"}
    ],
    "podIP": "10.244.1.2",
    "containerStatuses": [...]
  }
}
```

## **Phase 6: Service & Network Setup**

### **Step 16: Endpoints Controller**
```bash
# Endpoints Controller watches pods:
WATCH /api/v1/pods?labelSelector=app=nginx

# Updates Endpoints object:
PATCH /api/v1/namespaces/default/endpoints/nginx
{
  "subsets": [{
    "addresses": [{"ip": "10.244.1.2", "nodeName": "worker-node-1"}],
    "ports": [{"port": 80}]
  }]
}
```

### **Step 17: Kube-proxy**
```bash
# Kube-proxy watches Endpoints:
WATCH /api/v1/endpoints?watch=true

# Updates iptables/ipvs rules:
# Creates DNAT rules: ServiceIP:Port → PodIP:Port
```

## **Phase 7: Continuous Reconciliation**

### **Step 18: Health Monitoring**
```bash
# Kubelet runs probes every X seconds:
- Liveness probes: Restart container if fails
- Readiness probes: Remove from service endpoints if fails

# Status updates flow back:
Kubelet → API Server → ReplicaSet Controller
```

### **Step 19: Scale Up/Down**
```bash
# If user changes replicas:
kubectl scale deployment nginx --replicas=5

# Flow:
1. kubectl → API Server: Update Deployment replicas=5
2. etcd stores new value
3. Deployment Controller sees change
4. Updates ReplicaSet replicas=5  
5. ReplicaSet Controller creates 2 more pods
6. Repeat steps 8-17 for new pods
```

## **Complete Flow Summary:**
```
User → API Server → etcd
           ↓
Deployment Controller → ReplicaSet → Pods
           ↓
Scheduler → Pod Binding
           ↓
Kubelet → Container Runtime → Containers
           ↓
Endpoints Controller → Kube-proxy → Network
```

**Total steps: ~19 distinct operations across 6 components.**