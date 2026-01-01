# Kubernetes Gateway API: Complete Master Guide 🚀

## 🎯 **What is Gateway API?**

**Gateway API** is the **next-generation** official Kubernetes API for service networking (successor to Ingress).  
It's **more powerful, expressive, and role-oriented** than Ingress.

---

## 📊 **Gateway API vs Ingress: Key Differences**

| Feature | Ingress API | Gateway API |
|---------|------------|-------------|
| **API Version** | `networking.k8s.io/v1` | `gateway.networking.k8s.io/v1` |
| **Resource Types** | 1 (Ingress) | 4+ (Gateway, HTTPRoute, etc.) |
| **Role Separation** | No | Yes (Infra vs App teams) |
| **Protocol Support** | HTTP/HTTPS only | HTTP, TCP, UDP, TLS, gRPC |
| **Traffic Splitting** | Limited | Native (weight-based) |
| **Header Matching** | No | Yes |
| **Cross-namespace** | Limited | Fully supported |
| **Reference Grant** | No | Yes (for cross-ns) |

---

## 🏗️ **The 4 Core Resources of Gateway API**

### **1. GatewayClass 🏷️** - "Which Gateway implementation?"
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx-gateway-class
spec:
  controllerName: "nginx.org/gateway-controller"
  description: "NGINX Gateway Class"
  parametersRef:
    name: nginx-config
    group: nginx.org
    kind: GatewayClassConfig
```

**Purpose:** Defines a **class of Gateways** (like StorageClass for storage).

---

### **2. Gateway 🚪** - "The actual load balancer"
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: production-gateway
  namespace: infrastructure
spec:
  gatewayClassName: nginx-gateway-class
  listeners:
  - name: https-web
    port: 443
    protocol: HTTPS
    hostname: "*.example.com"
    tls:
      certificateRefs:
      - name: example-tls
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            environment: production
```

**Key Fields:**
- `listeners`: Ports and protocols Gateway accepts
- `allowedRoutes`: Which routes can attach (security boundary)
- `addresses`: IP/DNS of the Gateway

---

### **3. HTTPRoute 🛣️** - "Routing rules"
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: webapp-route
  namespace: app-team
spec:
  parentRefs:
  - name: production-gateway
    namespace: infrastructure
  hostnames:
  - "app.example.com"
  - "www.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: X-API-Version
          value: "v1"
    backendRefs:
    - name: api-service
      port: 8080
      weight: 80
    - name: api-service-v2
      port: 8080
      weight: 20
```

**Key Features:**
- **`matches`**: Path, header, query param matching
- **`filters`**: Request/response transformations
- **`backendRefs`**: Multiple backends with weights
- **`hostnames`**: Virtual hosting

---

### **4. ReferenceGrant 🔐** - "Cross-namespace security"
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-app-to-gateway
  namespace: infrastructure
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: app-team
  to:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: production-gateway
```

**Purpose:** Controls **cross-namespace references** (security boundary).

---

## 🎭 **Real-World Examples**

### **Example 1: Basic Routing**
```yaml
# Gateway
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: company-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP

# HTTPRoute for App
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
spec:
  parentRefs:
  - name: company-gateway
  hostnames:
  - "app.company.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-service
      port: 3000
```

### **Example 2: Canary Deployment**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-route
spec:
  parentRefs:
  - name: main-gateway
  hostnames:
  - "api.company.com"
  rules:
  - matches:
    - headers:
      - type: Exact
        name: X-Canary
        value: "true"
    backendRefs:
    - name: api-v2-service
      port: 8080
  - backendRefs:
    - name: api-v1-service
      port: 8080
      weight: 90
    - name: api-v2-service
      port: 8080
      weight: 10
```

### **Example 3: Header-Based Routing**
```yaml
rules:
- matches:
  - headers:
    - type: Exact
      name: X-Device-Type
      value: "mobile"
  backendRefs:
  - name: mobile-backend
    port: 8080
- matches:
  - headers:
    - type: Exact
      name: X-Device-Type
      value: "desktop"
  backendRefs:
  - name: desktop-backend
    port: 8080
```

### **Example 4: Path Rewriting**
```yaml
rules:
- matches:
  - path:
      type: PathPrefix
      value: /v1/api
  filters:
  - type: URLRewrite
    urlRewrite:
      path:
        type: ReplacePrefixMatch
        replacePrefixMatch: /api
  backendRefs:
  - name: api-service
    port: 8080
```

### **Example 5: Rate Limiting**
```yaml
rules:
- matches:
  - path:
      type: PathPrefix
      value: /api
  filters:
  - type: RequestMirror
    requestMirror:
      backendRef:
        name: logging-service
        port: 8080
  - type: ExtensionRef
    extensionRef:
      group: networking.example.io
      kind: RateLimitPolicy
      name: api-rate-limit
  backendRefs:
  - name: api-service
    port: 8080
```

---

## 🚀 **Implementation Controllers**

### **NGINX Gateway**
```bash
# Install
kubectl apply -f https://github.com/nginxinc/nginx-kubernetes-gateway/releases/latest/download/nginx-gateway.yaml

# GatewayClass
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: nginx
spec:
  controllerName: gateway.nginx.org/nginx-gateway-controller
```

### **Istio Gateway**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: istio
spec:
  controllerName: istio.io/gateway-controller
```

### **Contour Gateway**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: contour
spec:
  controllerName: projectcontour.io/gateway-controller
```

---

## 🔄 **Migration from Ingress to Gateway API**

### **Before (Ingress):**
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: app-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```

### **After (Gateway API):**
```yaml
# Gateway
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP

# HTTPRoute
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
spec:
  parentRefs:
  - name: shared-gateway
  hostnames:
  - "app.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /
    backendRefs:
    - name: api-service
      port: 8080
```

---

## 🎭 **Advanced Features**

### **1. TCPRoute (Layer 4 Routing)**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: TCPRoute
metadata:
  name: postgres-route
spec:
  parentRefs:
  - name: tcp-gateway
  rules:
  - backendRefs:
    - name: postgres-service
      port: 5432
```

### **2. TLSRoute**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: TLSRoute
metadata:
  name: tls-app
spec:
  parentRefs:
  - name: tls-gateway
  hostnames:
  - "secure.example.com"
  rules:
  - backendRefs:
    - name: backend-service
      port: 8443
```

### **3. GRPCRoute**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GRPCRoute
metadata:
  name: grpc-service
spec:
  parentRefs:
  - name: grpc-gateway
  hostnames:
  - "grpc.example.com"
  rules:
  - matches:
    - method:
        service: "helloworld.Greeter"
        method: "SayHello"
    backendRefs:
    - name: grpc-backend
      port: 50051
```

### **4. BackendTLSPolicy (mTLS)**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: BackendTLSPolicy
metadata:
  name: backend-tls
spec:
  targetRef:
    group: ""
    kind: Service
    name: secure-backend
    port: 8443
  tls:
    hostname: backend.internal
    caCertRefs:
    - name: ca-certificate
      group: ""
      kind: ConfigMap
```

---

## 🔧 **Troubleshooting & Commands**

### **Common kubectl commands:**
```bash
# List all Gateway API resources
kubectl get gatewayclass
kubectl get gateway -A
kubectl get httproutes -A
kubectl get referencegrants -A

# Describe resources
kubectl describe gateway production-gateway
kubectl describe httproutes -n app-team

# Check Gateway status
kubectl get gateway -o jsonpath='{.items[*].status}'

# Check admission webhook
kubectl get validatingwebhookconfigurations
kubectl get mutatingwebhookconfigurations

# Events
kubectl get events --field-selector involvedObject.kind=HTTPRoute
```

### **Status Conditions:**
```bash
# Check if Gateway is ready
kubectl get gateway my-gateway -o jsonpath='{.status.conditions[?(@.type=="Ready")]}'

# Check listener status
kubectl get gateway my-gateway -o jsonpath='{.status.listeners[*].conditions}'
```

### **Common Issues:**
1. **Gateway not ready** → Check GatewayClass exists
2. **HTTPRoute not attached** → Check parentRef namespace + ReferenceGrant
3. **No IP/DNS assigned** → Check cloud provider LoadBalancer
4. **Cross-namespace denied** → Missing ReferenceGrant

---

## 🏗️ **Multi-Team Architecture Example**

### **Infrastructure Team (Cluster Admin)**
```yaml
# gateway-infra.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: company-gateway-class
spec:
  controllerName: "nginx.org/gateway-controller"
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: gateway-system
spec:
  gatewayClassName: company-gateway-class
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-all-to-gateway
  namespace: gateway-system
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
  to:
  - group: gateway.networking.k8s.io
    kind: Gateway
```

### **App Team A (Payment Service)**
```yaml
# payment-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: payment-route
  namespace: payment-team
spec:
  parentRefs:
  - name: shared-gateway
    namespace: gateway-system
  hostnames:
  - "payments.example.com"
  rules:
  - backendRefs:
    - name: payment-service
      port: 8080
```

### **App Team B (User Service)**
```yaml
# user-route.yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: user-route
  namespace: user-team
spec:
  parentRefs:
  - name: shared-gateway
    namespace: gateway-system
  hostnames:
  - "users.example.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: user-service
      port: 8080
```

---

## 📊 **Comparison Table: HTTPRoute vs Ingress**

| Feature | Ingress | HTTPRoute |
|---------|---------|-----------|
| **Path Matching** | Prefix, Exact | Prefix, Exact, RegularExpression |
| **Header Matching** | ❌ No | ✅ Yes |
| **Query Param Matching** | ❌ No | ✅ Yes |
| **Method Matching** | ❌ No | ✅ Yes |
| **Weighted Traffic** | ❌ No | ✅ Yes |
| **Request Mirroring** | ❌ No | ✅ Yes |
| **Request/Response Modifiers** | Limited annotations | Native filters |
| **Cross-namespace** | Manual annotations | ReferenceGrant |
| **TCP/UDP** | ❌ No | ✅ Yes (TCPRoute) |
| **gRPC** | ❌ No | ✅ Yes (GRPCRoute) |

---

## 🚀 **Getting Started**

### **1. Install Gateway API CRDs**
```bash
# Latest release
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

# With experimental features
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/experimental-install.yaml
```

### **2. Install a Controller**
```bash
# NGINX Gateway
kubectl apply -f https://github.com/nginxinc/nginx-kubernetes-gateway/releases/latest/download/nginx-gateway.yaml

# Or Contour
kubectl apply -f https://projectcontour.io/quickstart/contour-gateway-provisioner.yaml
```

### **3. Create Your First Gateway**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: quickstart-gateway
spec:
  gatewayClassName: nginx
  listeners:
  - name: http
    port: 80
    protocol: HTTP
```

---

## 💡 **Best Practices**

1. **Use GatewayClass** for different environments (prod, staging, dev)
2. **Namespace isolation** with ReferenceGrant
3. **Use `hostnames`** for virtual hosting
4. **Weight-based routing** for canary deployments
5. **Health checks** on backendRefs
6. **Monitor Gateway status conditions**
7. **Start with HTTPRoute**, migrate TCP/GRPCRoute later
8. **Use filters** instead of annotations

---

## 🎯 **When to Use Gateway API?**

### **Use Gateway API when:**
- ✅ Need advanced routing (headers, methods, weights)
- ✅ Multi-team environment
- ✅ Cross-namespace routing
- ✅ Multiple protocols (HTTP, TCP, gRPC)
- ✅ Future-proofing (Ingress is deprecated long-term)

### **Use Ingress when:**
- ✅ Simple HTTP routing only
- ✅ Legacy applications
- ✅ Limited controller support needed
- ✅ Quick and simple setup

---

## 🔮 **Future of Gateway API**

### **Upcoming Features:**
- **Service APIs** (generalization beyond networking)
- **WASM filters** (WebAssembly extensions)
- **More protocol support** (QUIC, WebSocket)
- **Enhanced observability**
- **Policy attachments**

### **Adoption Timeline:**
- **v1.0** → GA (production ready)
- **v1.1** → More features stable
- **Future** → Replace Ingress entirely

---

## 📚 **Quick Reference**

### **Core Resources:**
```bash
GatewayClass     # Defines gateway implementation type
Gateway          # Instantiates a gateway (load balancer)
HTTPRoute        # HTTP routing rules
TCPRoute         # TCP routing rules
GRPCRoute        # gRPC routing rules
TLSRoute         # TLS passthrough routing
ReferenceGrant   # Cross-namespace security
```

### **Common kubectl commands:**
```bash
kubectl get gatewayclass
kubectl get gateway -A
kubectl get httproutes -A
kubectl describe gateway <name>
```

### **Sample Workflow:**
1. **Cluster Admin** creates GatewayClass
2. **Infra Team** creates Gateway
3. **App Teams** create HTTPRoutes
4. **Security Team** manages ReferenceGrants

---

**Gateway API is the future of Kubernetes networking.** It provides enterprise-grade features, role-based access, and protocol flexibility that Ingress never could. Start migrating today! 🚀