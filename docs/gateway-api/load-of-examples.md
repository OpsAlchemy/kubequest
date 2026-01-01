# Kubernetes Gateway API Complete Guide

## 🎯 **Gateway API Core Components**

### **1. GatewayClass** - The Gateway "Blueprint"
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: traefik-gateway-class
spec:
  controllerName: "traefik.io/gateway-controller"
  description: "Traefik implementation of Gateway API"
  parametersRef:
    name: traefik-config
    group: traefik.io
    kind: GatewayClassConfig
```

**Purpose:** Defines which controller implements this Gateway class.

---

### **2. Gateway** - The Actual Load Balancer
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: default
  labels:
    environment: production
    app: gateway
spec:
  gatewayClassName: traefik-gateway-class
  listeners:
  # HTTP Listener
  - name: http-web
    port: 80
    protocol: HTTP
    hostname: "*.example-app.com"
    allowedRoutes:
      namespaces:
        from: Same
  
  # HTTPS Listener  
  - name: https-web
    port: 443
    protocol: HTTPS
    hostname: "*.example-app.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: example-app-tls
        kind: Secret
        group: ""
    allowedRoutes:
      namespaces:
        from: All
```

**Key Points:**
- `listeners`: Defines ports, protocols, hostnames
- `allowedRoutes`: Security boundary (Same/All/Selector)
- `tls`: SSL/TLS configuration

---

## 🚀 **HTTPRoute - Traffic Management**

### **Route by Hostname**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: hostname-based-routing
  namespace: default
spec:
  parentRefs:
  - name: main-gateway
    namespace: default
  hostnames:
  - "example-app-python.com"
  - "example-app-go.com"
  
  rules:
  # Route Python domain
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: python-svc
      port: 5000
      weight: 100
  
  # Route Go domain  
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: go-svc
      port: 5000
      weight: 100
```

**How it works:**
- `example-app-python.com` → `python-svc:5000`
- `example-app-go.com` → `go-svc:5000`

---

### **Route by Path (Exact Match)**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: exact-path-routing
spec:
  parentRefs:
  - name: main-gateway
  hostnames:
  - "example-app.com"
  
  rules:
  # Exact match for /status
  - matches:
    - path:
        type: Exact
        value: /status
    backendRefs:
    - name: status-svc
      port: 8080
  
  # Exact match for /api/health
  - matches:
    - path:
        type: Exact
        value: /api/health
    backendRefs:
    - name: health-check-svc
      port: 8080
  
  # Prefix match for everything else
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: main-app-svc
      port: 80
```

**Path Types:**
- `Exact`: Only the exact path matches
- `PathPrefix`: Path and everything under it
- `RegularExpression`: Regex pattern matching

---

### **Route with URL Rewrite**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: url-rewrite-routing
spec:
  parentRefs:
  - name: main-gateway
  hostnames:
  - "example-app.com"
  
  rules:
  # Rewrite /api/python to backend root
  - matches:
    - path:
        type: PathPrefix
        value: /api/python
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /
    backendRefs:
    - name: python-svc
      port: 5000
  
  # Rewrite /api/go to backend root
  - matches:
    - path:
        type: PathPrefix
        value: /api/go
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /
    backendRefs:
    - name: go-svc
      port: 5000
  
  # Rewrite /api/go/status to /status on backend
  - matches:
    - path:
        type: PathPrefix
        value: /api/go/status
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplaceFullPath
          replaceFullPath: /status
    backendRefs:
    - name: go-svc
      port: 5000
```

**URL Rewrite Types:**
- `ReplacePrefixMatch`: Replace the matched prefix
- `ReplaceFullPath`: Replace entire path

---

### **Request/Response Header Manipulation**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-modification
spec:
  parentRefs:
  - name: main-gateway
  hostnames:
  - "api.example-app.com"
  
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api
    filters:
    # Request Header Modification
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: X-API-Version
          value: "v1"
        - name: X-Forwarded-For
          value: "$remote_addr"
        set:
        - name: X-Request-ID
          value: "$uuid"
        remove:
        - "X-Debug-Header"
    
    # Response Header Modification (CORS Example)
    - type: ResponseHeaderModifier
      responseHeaderModifier:
        add:
        - name: Access-Control-Allow-Origin
          value: "*"
        - name: Access-Control-Allow-Methods
          value: "GET, POST, PUT, DELETE, OPTIONS"
        - name: Access-Control-Allow-Headers
          value: "Content-Type, Authorization"
        - name: Access-Control-Max-Age
          value: "86400"
        set:
        - name: Cache-Control
          value: "no-cache, no-store, must-revalidate"
        remove:
        - "Server"  # Hide server info
    
    backendRefs:
    - name: api-svc
      port: 8080
```

**Header Operations:**
- `add`: Add header if not present
- `set`: Set header (overwrites if exists)
- `remove`: Remove header

---

### **HTTPS/TLS Configuration**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: tls-gateway
spec:
  gatewayClassName: traefik-gateway-class
  
  listeners:
  # HTTP Listener (Redirect to HTTPS)
  - name: http-redirect
    port: 80
    protocol: HTTP
    hostname: "example-app.com"
    allowedRoutes:
      namespaces:
        from: Same
  
  # HTTPS Listener
  - name: https-main
    port: 443
    protocol: HTTPS
    hostname: "example-app.com"
    tls:
      mode: Terminate  # TLS termination at gateway
      certificateRefs:
      - name: example-app-tls
        kind: Secret
        group: ""
    allowedRoutes:
      namespaces:
        from: Same
```

**TLS Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: example-app-tls
  namespace: default
type: kubernetes.io/tls
data:
  tls.crt: BASE64_ENCODED_CERT
  tls.key: BASE64_ENCODED_KEY
```

---

### **HTTPS Route with TLS**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: tls-route
spec:
  parentRefs:
  # Reference specific listener by sectionName
  - name: tls-gateway
    sectionName: https-main
  
  hostnames:
  - "example-app.com"
  
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /secure
    backendRefs:
    - name: secure-app-svc
      port: 8443
```

---

## 🔄 **Advanced Routing Patterns**

### **Weighted Traffic Splitting (Canary)**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: canary-deployment
spec:
  parentRefs:
  - name: main-gateway
  
  hostnames:
  - "app.example-app.com"
  
  rules:
  # Canary based on header
  - matches:
    - headers:
      - type: Exact
        name: X-Canary
        value: "true"
    backendRefs:
    - name: app-v2-svc
      port: 8080
  
  # Default: 90% v1, 10% v2
  - backendRefs:
    - name: app-v1-svc
      port: 8080
      weight: 90
    - name: app-v2-svc
      port: 8080
      weight: 10
```

---

### **Header-Based Routing**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: header-based-routing
spec:
  parentRefs:
  - name: main-gateway
  
  rules:
  # Mobile users
  - matches:
    - headers:
      - type: Regex
        name: User-Agent
        value: ".*(Android|iPhone|Mobile).*"
    backendRefs:
    - name: mobile-svc
      port: 8080
  
  # Desktop users
  - matches:
    - headers:
      - type: Regex
        name: User-Agent
        value: ".*(Windows|Macintosh|Linux).*"
    backendRefs:
    - name: desktop-svc
      port: 8080
  
  # API clients
  - matches:
    - headers:
      - type: Exact
        name: Content-Type
        value: "application/json"
    backendRefs:
    - name: api-svc
      port: 8080
```

---

### **Query Parameter Matching**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: query-param-routing
spec:
  parentRefs:
  - name: main-gateway
  
  rules:
  # Route based on version query param
  - matches:
    - queryParams:
      - type: Exact
        name: version
        value: "v2"
    backendRefs:
    - name: v2-svc
      port: 8080
  
  # Route based on debug flag
  - matches:
    - queryParams:
      - type: Exact
        name: debug
        value: "true"
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: X-Debug-Mode
          value: "enabled"
    backendRefs:
    - name: debug-svc
      port: 8080
```

---

### **Method-Based Routing**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: method-based-routing
spec:
  parentRefs:
  - name: main-gateway
  
  rules:
  # GET requests to read-only service
  - matches:
    - method: GET
      path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: read-svc
      port: 8080
  
  # POST/PUT/DELETE to write service
  - matches:
    - method: POST
      path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: write-svc
      port: 8080
  
  - matches:
    - method: PUT
      path:
        type: PathPrefix
        value: /api
    backendRefs:
    - name: write-svc
      port: 8080
```

---

## 🔧 **Filters - Request/Response Transformations**

### **Redirect Filter**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: redirect-routes
spec:
  parentRefs:
  - name: main-gateway
  
  rules:
  # Permanent redirect (301)
  - matches:
    - path:
        type: Exact
        value: /old-path
    filters:
    - type: RequestRedirect
      requestRedirect:
        scheme: https
        hostname: "new.example-app.com"
        path:
          type: ReplaceFullPath
          replaceFullPath: /new-path
        statusCode: 301
  
  # Temporary redirect with port change
  - matches:
    - path:
        type: Exact
        value: /temp
    filters:
    - type: RequestRedirect
      requestRedirect:
        port: 8443
        statusCode: 302
```

---

### **Request Mirroring**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: request-mirroring
spec:
  parentRefs:
  - name: main-gateway
  
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /api/payments
    filters:
    # Mirror 10% of payment requests for auditing
    - type: RequestMirror
      requestMirror:
        backendRef:
          name: audit-svc
          port: 8080
        weight: 10  # Percentage to mirror
    
    backendRefs:
    - name: payment-svc
      port: 8080
```

---

## 🏗️ **Cross-Namespace Routing**

### **Gateway with Namespace Selector**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: shared-gateway
  namespace: infrastructure
spec:
  gatewayClassName: traefik-gateway-class
  
  listeners:
  - name: shared-http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: Selector
        selector:
          matchLabels:
            shared-gateway: enabled
```

### **ReferenceGrant (Security Boundary)**
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-app-team
  namespace: infrastructure
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: app-team
  
  to:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: shared-gateway
```

### **HTTPRoute in Different Namespace**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: app-team
  labels:
    shared-gateway: enabled
spec:
  parentRefs:
  - name: shared-gateway
    namespace: infrastructure
  
  hostnames:
  - "app.example-app.com"
  
  rules:
  - backendRefs:
    - name: app-svc
      namespace: app-team
      port: 8080
```

---

## 📊 **Complete Example: API Gateway Pattern**

```yaml
# Gateway
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: api-gateway
spec:
  gatewayClassName: traefik-gateway-class
  
  listeners:
  - name: api-http
    port: 80
    protocol: HTTP
    hostname: "api.example-app.com"
  
  - name: api-https
    port: 443
    protocol: HTTPS
    hostname: "api.example-app.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: api-tls-cert

# Main API Route
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-main-route
spec:
  parentRefs:
  - name: api-gateway
  
  hostnames:
  - "api.example-app.com"
  
  rules:
  # Health check endpoint
  - matches:
    - path:
        type: Exact
        value: /health
    backendRefs:
    - name: health-svc
      port: 8080
  
  # Users API with versioning
  - matches:
    - path:
        type: PathPrefix
        value: /v1/users
    filters:
    - type: RequestHeaderModifier
      requestHeaderModifier:
        add:
        - name: X-API-Version
          value: "v1"
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /users
    backendRefs:
    - name: user-svc
      port: 8080
  
  # Products API
  - matches:
    - path:
        type: PathPrefix
        value: /v1/products
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /products
    backendRefs:
    - name: product-svc
      port: 8080
  
  # Orders API with CORS
  - matches:
    - path:
        type: PathPrefix
        value: /v1/orders
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /orders
    - type: ResponseHeaderModifier
      responseHeaderModifier:
        add:
        - name: Access-Control-Allow-Origin
          value: "https://app.example-app.com"
    backendRefs:
    - name: order-svc
      port: 8080
  
  # Default 404
  - matches:
    - path:
        type: PathPrefix
        value: /
    filters:
    - type: RequestRedirect
      requestRedirect:
        statusCode: 404
```

---

## 🎯 **Key Concepts Summary**

### **Parent References**
```yaml
parentRefs:
- name: gateway-name
  namespace: gateway-namespace
  sectionName: listener-name  # Optional: target specific listener
  port: 80                   # Optional: target specific port
```

### **Hostname Matching**
```yaml
hostnames:
- "exact.example.com"        # Exact match
- "*.example.com"            # Wildcard subdomain
- "example.com"              # Exact + www redirects
```

### **Match Conditions**
```yaml
matches:
- path:                      # Path matching
    type: PathPrefix         # or Exact, or RegularExpression
    value: /api
  
  headers:                   # Header matching
  - type: Exact              # or Regex
    name: X-Custom-Header
    value: expected-value
  
  queryParams:               # Query parameter matching
  - type: Exact
    name: version
    value: v2
  
  method: GET                # HTTP method matching
```

### **Filters (In Order of Execution)**
```yaml
filters:
- type: RequestHeaderModifier  # 1. Modify request headers
- type: ResponseHeaderModifier # 2. Modify response headers
- type: RequestRedirect        # 3. Redirect request
- type: URLRewrite            # 4. Rewrite URL
- type: RequestMirror         # 5. Mirror request
- type: ExtensionRef          # 6. Custom extensions
```

### **Backend References**
```yaml
backendRefs:
- name: service-name
  port: 8080
  weight: 80                  # For traffic splitting
  filters:                    # Backend-specific filters
  - type: ExtensionRef
    extensionRef:
      name: retry-policy
```

---

## 🔧 **Infrastructure Labels & Annotations**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: cloud-gateway
  annotations:
    # Cloud-specific configurations
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
    
    # Controller-specific
    traefik.ingress.kubernetes.io/router.middlewares: "default-compress@file"
    
  labels:
    # Gateway API infrastructure labels
    gateway.networking.k8s.io/infrastructure: "aws-nlb"
    environment: "production"
```

---

## 📝 **Best Practices**

1. **Use GatewayClass** for different environments
2. **Namespace isolation** with ReferenceGrant
3. **Clear hostname strategy** (wildcard vs exact)
4. **Order matches carefully** (first match wins)
5. **Use filters sparingly** (performance impact)
6. **Monitor Gateway status** conditions
7. **Test cross-namespace** routing thoroughly
8. **Document route purposes** in metadata

---

## 🚀 **Quick Start Checklist**

1. ✅ Install Gateway API CRDs
2. ✅ Install Gateway controller (Traefik, NGINX, Istio, Envoy)
3. ✅ Create GatewayClass
4. ✅ Create Gateway with listeners
5. ✅ Create HTTPRoute for routing logic
6. ✅ Test hostname/path matching
7. ✅ Add filters for transformations
8. ✅ Configure TLS for HTTPS
9. ✅ Set up cross-namespace (if needed)
10. ✅ Add monitoring and observability

---

**Gateway API provides a clean, declarative way to manage traffic in Kubernetes with enterprise-grade features that Ingress could never offer. Start simple, add complexity as you need it!** 🎉