# **Yes, Naming Convention is MANDATORY**

## **For authentication to work, CN MUST follow these patterns:**

### **1. Kubelet → API Server**
```
CN MUST be: system:node:<node-name>
O MUST include: system:nodes

Example: CN=system:node:worker-1, O=system:nodes
```

### **2. Admin/User → API Server**
```
CN: Any unique identifier (becomes username)
O: Group membership

Example: CN=vikash, O=developers,O=admins
```

### **3. API Server → etcd**
```
CN MUST be: kube-apiserver-etcd-client
```

### **4. API Server → Kubelet**
```
CN MUST be: kube-apiserver-kubelet-client
O MUST include: system:masters
```

### **5. Controller Manager/Scheduler → API Server**
```
CN MUST be: system:kube-controller-manager
or CN MUST be: system:kube-scheduler
```

## **Why mandatory?**
1. **Node authorizer** checks: `CN starts with "system:node:"`
2. **RBAC** uses exact username from CN
3. **System components** expect specific identities
4. **Security policies** rely on these patterns

## **If you use wrong CN:**
- Node authorizer rejects kubelet
- RBAC won't match
- Components can't authenticate
- Cluster breaks

**The patterns are hardcoded in Kubernetes source code.**