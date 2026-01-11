# **Kubernetes Component Interactions - List Only**

## **1. User → API Server**
1. kubectl → API Server (REST API)
2. Dashboard → API Server
3. CI/CD tools → API Server

## **2. API Server ↔ Storage**
4. API Server → etcd (CRUD operations)
5. API Server ← etcd (watch changes)



# **You're RIGHT! Let me correct:**

## **Complete mTLS between API Server ↔ etcd:**

### **Both sides need:**

**API Server has:**
1. ✅ **Client certificate:** `apiserver-etcd-client.crt`
2. ✅ **Client private key:** `apiserver-etcd-client.key`
3. ✅ **etcd CA:** `etcd/ca.crt` (to verify etcd's server cert)

**etcd has:**
1. ✅ **Server certificate:** `etcd/server.crt`
2. ✅ **Server private key:** `etcd/server.key`
3. ✅ **etcd CA:** `etcd/ca.crt` (to verify API Server's client cert)

## **Complete TLS Handshake:**

```
API Server (client) ↔ etcd (server)

API Server → etcd:
- Presents: apiserver-etcd-client.crt + signs with apiserver-etcd-client.key

etcd → API Server:
- Presents: etcd/server.crt + signs with etcd/server.key

Both verify using SAME etcd/ca.crt
```

## **Why same CA for both?**

Because:
1. `apiserver-etcd-client.crt` signed by **etcd CA**
2. `etcd/server.crt` signed by **etcd CA**  
3. Both trust **etcd CA** (`etcd/ca.crt`)

**Yes, both sides have certificates, private keys, and share the same CA.**



## **3. API Server ↔ Controllers**
6. API Server → Controller Manager (watch events)
7. Controller Manager → API Server (update resources)
8. API Server → Scheduler (watch unscheduled pods)
9. Scheduler → API Server (bind pods to nodes)

## **4. API Server ↔ Nodes**
10. API Server → Kubelet (pod assignments)
11. Kubelet → API Server (node/pod status)
12. API Server → Kube-proxy (service/endpoint updates)
13. Kube-proxy → API Server (watch services)

## **5. Node Internal**
14. Kubelet → Container Runtime (CRI)
15. Kubelet → CSI Driver (volume operations)
16. Kubelet → Device Plugin (hardware resources)
17. Kube-proxy → iptables/ipvs (network rules)

## **6. Controller ↔ Controller**
18. Various controllers → API Server (reconciliation)
19. Cloud Controller → Cloud Provider API

## **7. Pod ↔ Pod**
20. Pod → Service → Pod (network)
21. Pod → DNS (CoreDNS)
22. Pod → API Server (service account)

## **8. Addons**
23. Metrics Server → Kubelet (metrics)
24. CoreDNS → API Server (watch services)
25. Ingress Controller → API Server (watch ingresses)

## **9. Cloud Integration**
26. Cloud Controller → Cloud API (load balancers, volumes)
27. Node → Cloud Metadata Service

## **10. Monitoring**
28. Prometheus → API Server (discovery)
29. Prometheus → Kubelet (metrics)

**Total: 29 distinct interaction paths.**