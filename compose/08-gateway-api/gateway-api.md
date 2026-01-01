# Kubernetes Gateway API

## **Core Architecture**

### **Three-Tier Model:**
1. **GatewayClass** → Which controller implementation to use
2. **Gateway** → Actual load balancer with listeners  
3. **HTTPRoute/TCPRoute/TLSRoute** → Routing rules and logic

## **Complete YAML Examples (All Fields Explained)**

### **GatewayClass - All Possible Fields:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: traefik
spec:
  # REQUIRED: Which controller implements this
  controllerName: "traefik.io/gateway-controller"
  
  # OPTIONAL: Description
  description: "Traefik GatewayClass for production"
  
  # OPTIONAL: Controller-specific parameters
  parametersRef:
    name: traefik-config
    group: traefik.io
    kind: GatewayClassConfig
```

### **Gateway - Complete with All Listeners:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: traefik
spec:
  # REQUIRED: Which GatewayClass to use
  gatewayClassName: traefik
  
  # REQUIRED: At least one listener
  listeners:
  - name: http-public
    port: 80
    protocol: HTTP
    
    # OPTIONAL: Restrict hostnames
    hostname: "*.example-app.com"
    
    # OPTIONAL: TLS (for HTTPS/TLS listeners only)
    # tls:
    #   mode: Terminate
    #   certificateRefs: []
    
    # OPTIONAL: Which namespaces can attach routes
    allowedRoutes:
      namespaces:
        from: Same  # Same, All, or Selector
        # selector:  # When from: Selector
        #   matchLabels:
        #     shared-gateway: "true"
  
  # HTTPS Listener Example  
  - name: https-secure
    port: 443
    protocol: HTTPS
    
    hostname: "example-app.com"
    
    # REQUIRED for HTTPS: TLS configuration
    tls:
      mode: Terminate  # or Passthrough
      certificateRefs:
      - name: secret-tls
        kind: Secret
        group: ""
      # options:  # Optional TLS options
      #   cipherSuites: []
      #   minVersion: "TLSv1.2"
    
    allowedRoutes:
      namespaces:
        from: All
  
  # TCP Listener Example (Experimental)
  - name: tcp-database
    port: 5432
    protocol: TCP
    
    allowedRoutes:
      namespaces:
        from: Same
```

**Listener Protocol Types:**
- `HTTP` → For HTTPRoute
- `HTTPS` → For HTTPRoute with TLS
- `TLS` → For TLSRoute (passthrough)  
- `TCP` → For TCPRoute
- `UDP` → For UDPRoute (experimental)

**TLS Modes:**
- `Terminate` → TLS ends at Gateway (decrypts)
- `Passthrough` → TLS continues to backend

## **HTTPRoute - Complete with All Features**

### **Route by Hostname (From README):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: go
spec:
  # REQUIRED: Attach to which Gateway
  parentRefs:
  - name: traefik
    # namespace: default  # If Gateway in different namespace
    # sectionName: web    # Target specific listener
    # port: 80           # Target specific port
  
  # OPTIONAL: Which hostnames to match
  hostnames:
  - "example-app-go.com"
  - "*.test.example-app-go.com"  # Wildcard subdomains
  
  # REQUIRED: At least one rule
  rules:
  - matches:
    # Path matching (choose one type)
    - path:
        type: PathPrefix  # Exact, PathPrefix, or RegularExpression
        value: "/"
    
    # OPTIONAL: Header matching
    # headers:
    # - type: Exact  # or RegularExpression
    #   name: "X-API-Version"
    #   value: "v2"
    
    # OPTIONAL: Query parameter matching  
    # queryParams:
    # - type: Exact
    #   name: "debug"
    #   value: "true"
    
    # OPTIONAL: HTTP method matching
    # method: "GET"  # GET, POST, PUT, DELETE, etc.
    
    # OPTIONAL: Request filters (applied in order)
    filters:
    # - type: RequestHeaderModifier
    #   requestHeaderModifier:
    #     set:    # Overwrite if exists
    #     - name: "X-Request-ID"
    #       value: "{{uuid}}"
    #     add:    # Add if not exists
    #     - name: "X-Forwarded-For"
    #       value: "$remote_addr"
    #     remove: # Remove headers
    #     - "X-Secret-Header"
    
    # - type: ResponseHeaderModifier
    #   responseHeaderModifier:
    #     add:
    #     - name: "Cache-Control"
    #       value: "max-age=3600"
    
    # - type: RequestRedirect
    #   requestRedirect:
    #     scheme: "https"
    #     hostname: "secure.example.com"
    #     port: 443
    #     statusCode: 301
    
    # - type: URLRewrite
    #   urlRewrite:
    #     path:
    #       type: ReplacePrefixMatch  # or ReplaceFullPath
    #       replacePrefixMatch: "/v2"
    
    # - type: RequestMirror
    #   requestMirror:
    #     backendRef:
    #       name: audit-service
    #       port: 8080
    
    # - type: ExtensionRef
    #   extensionRef:
    #     name: custom-filter
    #     kind: CustomFilter
    #     group: example.com
    
    # REQUIRED: Where to send traffic
    backendRefs:
    - name: go-svc
      port: 5000
      # weight: 100  # For traffic splitting (0-100)
      # filters: []  # Backend-specific filters
    
    # Multiple backends for traffic splitting
    # - name: go-svc-v2
    #   port: 5000
    #   weight: 20
```

### **Route by Path - Exact Match:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: python-exact
spec:
  parentRefs:
  - name: traefik
  hostnames:
  - "example-app-python.com"
  rules:
  - matches:
    - path:
        type: Exact  # Only "/" matches
        value: "/"
    backendRefs:
    - name: python-svc
      port: 5000
```

### **Route by Path - Prefix Match:**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: python-prefix
spec:
  parentRefs:
  - name: traefik
  hostnames:
  - "example-app-python.com"
  rules:
  - matches:
    - path:
        type: PathPrefix  # "/", "/api", "/api/users" all match
        value: "/"
    backendRefs:
    - name: python-svc
      port: 5000
```

### **URL Rewrite Pattern (API Gateway):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-gateway
spec:
  parentRefs:
  - name: traefik
  hostnames:
  - "example-app.com"
  rules:
  # Python service
  - matches:
    - path:
        type: PathPrefix
        value: "/api/python"
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: "/"
    backendRefs:
    - name: python-svc
      port: 5000
  
  # Go service
  - matches:
    - path:
        type: PathPrefix
        value: "/api/go"
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: "/"
    backendRefs:
    - name: go-svc
      port: 5000
```

**URL Rewrite Types:**
- `ReplacePrefixMatch` → Replace matched prefix only
- `ReplaceFullPath` → Replace entire path

### **Header Modification (CORS Example):**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: go-cors
spec:
  parentRefs:
  - name: traefik
  hostnames:
  - "example-app.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: "/api/go"
    filters:
    - type: ResponseHeaderModifier
      responseHeaderModifier:
        add:
        - name: "Access-Control-Allow-Origin"
          value: "*"
        - name: "Access-Control-Allow-Methods"
          value: "GET, POST, PUT, DELETE, OPTIONS"
        - name: "Access-Control-Allow-Headers"
          value: "Content-Type, Authorization"
        - name: "Access-Control-Max-Age"
          value: "86400"
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: "/"
    backendRefs:
    - name: go-svc
      port: 5000
```

### **HTTPS/TLS Configuration:**
```yaml
# Updated Gateway with TLS
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: traefik
spec:
  gatewayClassName: traefik
  listeners:
  - name: web
    port: 80
    protocol: HTTP
    hostname: "*.example-app.com"
  
  - name: web-secure
    port: 443
    protocol: HTTPS
    hostname: "*.example-app.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: secret-tls

# HTTPRoute targeting TLS listener
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: go-tls
spec:
  parentRefs:
  - name: traefik
    sectionName: web-secure  # Target HTTPS listener
  hostnames:
  - "example-app.com"
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: "/api/go"
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: "/"
    backendRefs:
    - name: go-svc
      port: 5000
```

## **Other Route Types (Experimental)**

### **TCPRoute:**
```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TCPRoute
metadata:
  name: postgres-route
spec:
  parentRefs:
  - name: traefik
  rules:
  - backendRefs:
    - name: postgres-service
      port: 5432
```

### **TLSRoute:**
```yaml
apiVersion: gateway.networking.k8s.io/v1alpha2
kind: TLSRoute
metadata:
  name: tls-passthrough
spec:
  parentRefs:
  - name: traefik
  hostnames:
  - "secure.example-app.com"
  rules:
  - backendRefs:
    - name: backend-service
      port: 8443
```

## **Supporting Resources**

### **TLS Secret:**
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: secret-tls
type: kubernetes.io/tls
data:
  tls.crt: BASE64_ENCODED_CERT
  tls.key: BASE64_ENCODED_KEY
```

### **ReferenceGrant (Cross-Namespace):**
```yaml
apiVersion: gateway.networking.k8s.io/v1beta1
kind: ReferenceGrant
metadata:
  name: allow-routes
  namespace: gateway-namespace
spec:
  from:
  - group: gateway.networking.k8s.io
    kind: HTTPRoute
    namespace: app-namespace
  
  to:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: shared-gateway
```

## **Testing Commands**

### **Local Testing with kind:**
```bash
# Update /etc/hosts
127.0.0.1 example-app.com
127.0.0.1 example-app-go.com
127.0.0.1 example-app-python.com

# Port forward
kubectl -n traefik port-forward svc/traefik 80
kubectl -n traefik port-forward svc/traefik 443

# Test HTTP
curl -H "Host: example-app-go.com" http://localhost
curl -H "Host: example-app-python.com" http://localhost
curl -H "Host: example-app.com" http://localhost/api/go

# Test HTTPS
curl -k -H "Host: example-app.com" https://localhost:443/api/go
```

## **Key Concepts**

### **Traffic Flow:**
```
Request → Gateway (listener) → HTTPRoute (match) → Filters → Backend Service
```

### **Required Fields:**
- **GatewayClass**: `controllerName`
- **Gateway**: `gatewayClassName`, `listeners` (with `name`, `port`, `protocol`)
- **HTTPRoute**: `parentRefs`, `rules` (with `backendRefs`)

### **Optional But Important:**
- `hostnames` → Virtual hosting
- `tls` → HTTPS/TLS
- `allowedRoutes` → Security boundaries
- `filters` → Transformations
- `sectionName` → Target specific listener

### **Path Matching Types:**
- `Exact` → Only exact path
- `PathPrefix` → Path and everything under it
- `RegularExpression` → Regex pattern

### **Filter Types:**
1. `RequestHeaderModifier` → Modify request headers
2. `ResponseHeaderModifier` → Modify response headers
3. `URLRewrite` → Rewrite URL path
4. `RequestRedirect` → Redirect to different URL
5. `RequestMirror` → Mirror traffic
6. `ExtensionRef` → Custom filters

## **Infrastructure Labels**
```yaml
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: cloud-gateway
  labels:
    gateway.networking.k8s.io/infrastructure: "aws-nlb"
    environment: "production"
  annotations:
    service.beta.kubernetes.io/aws-load-balancer-type: "nlb"
    service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
```

**Purpose:** Propagate labels/annotations to cloud infrastructure.

## **Available Controllers**
- **Traefik** → Used in README, simple setup
- **Envoy** → High-performance proxy
- **Istio** → Service mesh integration
- **NGINX Fabric** → NGINX-based implementation

---