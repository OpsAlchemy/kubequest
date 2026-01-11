****# **Service Creation - Complete Step-by-Step**

## **Phase 1: User Creates Service**

### **Step 1: User Command**
```bash
kubectl apply -f service.yaml
# OR
kubectl expose deployment nginx --port=80 --target-port=80
```

### **Step 2: Service YAML**
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx-service
  namespace: default
spec:
  selector:
    app: nginx      # Selects pods with label app=nginx
  ports:
  - port: 80        # Service port
    targetPort: 80  # Pod container port
  type: ClusterIP   # Default
```

### **Step 3: kubectl → API Server**
```bash
POST /api/v1/namespaces/default/services
Content-Type: application/json

{
  "apiVersion": "v1",
  "kind": "Service",
  "metadata": {
    "name": "nginx-service",
    "namespace": "default"
  },
  "spec": {
    "selector": {"app": "nginx"},
    "ports": [{"port": 80, "targetPort": 80}],
    "type": "ClusterIP"
  }
}
```

## **Phase 2: API Server Processing**

### **Step 4: Validation & Storage**
```bash
# API Server:
1. Validates Service spec
2. Allocates ClusterIP from service CIDR (e.g., 10.96.0.0/12)
   - Example: 10.96.123.45
3. Stores in etcd:
   PUT /registry/services/default/nginx-service
   
# Returns: Service object with allocated ClusterIP
{
  "spec": {
    "clusterIP": "10.96.123.45",  # ← Assigned here
    "ports": [...],
    "selector": {...}
  }
}
```

## **Phase 3: Endpoints Controller Action**

### **Step 5: Endpoints Controller Watches**
```bash
# Endpoints Controller (in controller-manager) watches:
WATCH /api/v1/services?watch=true

# Event received:
{
  "type": "ADDED",
  "object": {
    "metadata": {"name": "nginx-service"},
    "spec": {
      "selector": {"app": "nginx"},
      "clusterIP": "10.96.123.45"
    }
  }
}
```

### **Step 6: Find Matching Pods**
```bash
# Endpoints Controller queries API Server:
GET /api/v1/namespaces/default/pods?labelSelector=app=nginx

# Response: List of pods with IPs
{
  "items": [
    {
      "metadata": {"name": "nginx-pod-1"},
      "status": {
        "podIP": "10.244.1.2",
        "conditions": [{"type": "Ready", "status": "True"}]
      }
    },
    {
      "metadata": {"name": "nginx-pod-2"}, 
      "status": {
        "podIP": "10.244.1.3",
        "conditions": [{"type": "Ready", "status": "True"}]
      }
    }
  ]
}
```

### **Step 7: Create/Update Endpoints Object**
```bash
# Endpoints Controller creates Endpoints object:
POST /api/v1/namespaces/default/endpoints
{
  "apiVersion": "v1",
  "kind": "Endpoints",
  "metadata": {
    "name": "nginx-service"  # Same name as Service!
  },
  "subsets": [{
    "addresses": [
      {
        "ip": "10.244.1.2",
        "nodeName": "worker-1",
        "targetRef": {
          "kind": "Pod",
          "name": "nginx-pod-1",
          "namespace": "default"
        }
      },
      {
        "ip": "10.244.1.3",
        "nodeName": "worker-2",
        "targetRef": {
          "kind": "Pod",
          "name": "nginx-pod-2",
          "namespace": "default"
        }
      }
    ],
    "ports": [{"port": 80}]
  }]
}
```

**Note**: Endpoints is a separate object from Service!

## **Phase 4: Kube-proxy Actions (on EVERY node)**

### **Step 8: Kube-proxy Watches Services & Endpoints**
```bash
# Each kube-proxy watches TWO streams:
1. WATCH /api/v1/services?watch=true
2. WATCH /api/v1/endpoints?watch=true

# Receives events:
Service ADDED: {"clusterIP": "10.96.123.45", "ports": [80]}
Endpoints ADDED: {"subsets": [{"addresses": [{"ip": "10.244.1.2"}, ...]}]}
```

### **Step 9: iptables Mode (Traditional)**

**On each node, kube-proxy creates iptables rules:**

```bash
# 1. Create KUBE-SERVICES chain
iptables -t nat -N KUBE-SERVICES

# 2. Jump to KUBE-SERVICES from OUTPUT/PREROUTING
iptables -t nat -A OUTPUT -m comment --comment "kubernetes service portals" -j KUBE-SERVICES
iptables -t nat -A PREROUTING -m comment --comment "kubernetes service portals" -j KUBE-SERVICES

# 3. Create service-specific chain
iptables -t nat -N KUBE-SVC-XXXXXXXX  # Hash of service name

# 4. Route to service chain
iptables -t nat -A KUBE-SERVICES -d 10.96.123.45/32 -p tcp --dport 80 \
  -m comment --comment "default/nginx-service:" -j KUBE-SVC-XXXXXXXX

# 5. Load balancing rules (random)
iptables -t nat -A KUBE-SVC-XXXXXXXX -m statistic --mode random --probability 0.5 \
  -m comment --comment "default/nginx-service:" -j KUBE-SEP-AAAAAAA
iptables -t nat -A KUBE-SVC-XXXXXXXX -m comment --comment "default/nginx-service:" -j KUBE-SEP-BBBBBBB

# 6. Endpoint rules
iptables -t nat -N KUBE-SEP-AAAAAAA
iptables -t nat -A KUBE-SEP-AAAAAAA -s 10.244.1.2/32 -m comment --comment "default/nginx-service:" -j KUBE-MARK-MASQ
iptables -t nat -A KUBE-SEP-AAAAAAA -p tcp -m comment --comment "default/nginx-service:" -j DNAT --to-destination 10.244.1.2:80

iptables -t nat -N KUBE-SEP-BBBBBBB
iptables -t nat -A KUBE-SEP-BBBBBBB -s 10.244.1.3/32 -m comment --comment "default/nginx-service:" -j KUBE-MARK-MASQ
iptables -t nat -A KUBE-SEP-BBBBBBB -p tcp -m comment --comment "default/nginx-service:" -j DNAT --to-destination 10.244.1.3:80
```

### **Step 10: IPVS Mode (Modern)**

```bash
# 1. Create virtual service
ipvsadm -A -t 10.96.123.45:80 -s rr  # Round-robin scheduling

# 2. Add real servers (pod IPs)
ipvsadm -a -t 10.96.123.45:80 -r 10.244.1.2:80 -m
ipvsadm -a -t 10.96.123.45:80 -r 10.244.1.3:80 -m
```

## **Phase 5: DNS Setup**

### **Step 11: CoreDNS Watches**
```bash
# CoreDNS watches Services:
WATCH /api/v1/services?watch=true

# Event received: Service ADDED with clusterIP
```

### **Step 12: DNS Record Creation**
```bash
# CoreDNS adds DNS records:
nginx-service.default.svc.cluster.local. IN A 10.96.123.45
# Also SRV record for port discovery
```

## **Phase 6: Network Programming Complete**

### **Step 13: Network Flow**
Now when a pod talks to the service:

```
Pod → Service (nginx-service:80 or 10.96.123.45:80)
     ↓ (iptables/IPVS on host node intercepts)
     ↓ (DNAT: 10.96.123.45:80 → 10.244.1.2:80)
     ↓
Target Pod (10.244.1.2:80)
```

## **Phase 7: Continuous Updates**

### **Step 14: Pod Changes**
```bash
# When pod dies and new one created:
1. Kubelet updates pod status → API Server
2. Endpoints Controller sees pod IP removed
3. Updates Endpoints object (remove old IP, add new IP)
4. Kube-proxy watches Endpoints update
5. Updates iptables/IPVS rules
```

### **Step 15: Service Updates**
```bash
# When Service selector changes:
1. User updates Service selector (app: nginx → app: new-app)
2. API Server stores update
3. Endpoints Controller:
   - Finds OLD pods (app=nginx) → remove from Endpoints
   - Finds NEW pods (app=new-app) → add to Endpoints
4. Kube-proxy updates rules
```

## **Summary of Objects Created:**

1. **Service**: `nginx-service` (ClusterIP assigned)
2. **Endpoints**: `nginx-service` (pod IPs list)  
3. **iptables/IPVS rules**: On every node
4. **DNS record**: In CoreDNS

## **Complete Data Flow:**

```
User → API Server → etcd
           ↓
Endpoints Controller → Watches Pods → Updates Endpoints
           ↓
Kube-proxy (every node) → Watches Service+Endpoints → Updates iptables/IPVS
           ↓  
CoreDNS → Watches Services → Updates DNS
```

**Service is virtual - just an IP + iptables rules. Endpoints hold actual pod IPs. Kube-proxy makes them work together.**