# Gateway API Practice Questions with Complete Solutions

## **Setup Script (Run First)**
```bash
#!/bin/bash

# Create cluster
kind create cluster --name gateway-practice --image kindest/node:v1.28.0

# Install Gateway API CRDs
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

# Deploy all test applications
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: practice-apps
---
# Frontend Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 8080
        env:
        - name: APP_NAME
          value: "frontend-app"
        volumeMounts:
        - name: config
          mountPath: /usr/share/nginx/html
      volumes:
      - name: config
        configMap:
          name: frontend-config
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: frontend-config
  namespace: practice-apps
data:
  index.html: |
    <html>
      <body>
        <h1>Frontend Service</h1>
        <p>Serving on port 8080</p>
      </body>
    </html>
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: practice-apps
spec:
  selector:
    app: frontend
  ports:
  - port: 8080
    targetPort: 8080
---
# Backend Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
    spec:
      containers:
      - name: node
        image: node:18-alpine
        command: ["node", "-e", "
          const http = require('http');
          const server = http.createServer((req, res) => {
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.end('Backend API Service on port 3000\\nPath: ' + req.url);
          });
          server.listen(3000, () => console.log('Backend listening on 3000'));
        "]
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: practice-apps
spec:
  selector:
    app: backend
  ports:
  - port: 3000
    targetPort: 3000
---
# Product Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: product
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: product
  template:
    metadata:
      labels:
        app: product
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 8080
        env:
        - name: SERVICE_TYPE
          value: "product"
---
apiVersion: v1
kind: Service
metadata:
  name: product-service
  namespace: practice-apps
spec:
  selector:
    app: product
  ports:
  - port: 8080
    targetPort: 8080
---
# Cart Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: cart
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cart
  template:
    metadata:
      labels:
        app: cart
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 9090
        env:
        - name: SERVICE_TYPE
          value: "cart"
---
apiVersion: v1
kind: Service
metadata:
  name: cart-service
  namespace: practice-apps
spec:
  selector:
    app: cart
  ports:
  - port: 9090
    targetPort: 9090
---
# Auth Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: auth
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: auth
  template:
    metadata:
      labels:
        app: auth
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 7070
        env:
        - name: SERVICE_TYPE
          value: "auth"
---
apiVersion: v1
kind: Service
metadata:
  name: auth-service
  namespace: practice-apps
spec:
  selector:
    app: auth
  ports:
  - port: 7070
    targetPort: 7070
---
# Health Check Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: health-check
  namespace: practice-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: health-check
  template:
    metadata:
      labels:
        app: health-check
    spec:
      containers:
      - name: node
        image: node:18-alpine
        command: ["node", "-e", "
          const http = require('http');
          const server = http.createServer((req, res) => {
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.end('Health: OK\\n');
          });
          server.listen(8080, () => console.log('Health check on 8080'));
        "]
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: health-check
  namespace: practice-apps
spec:
  selector:
    app: health-check
  ports:
  - port: 8080
    targetPort: 8080
---
# User Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: user-service
  namespace: practice-apps
spec:
  replicas: 2
  selector:
    matchLabels:
      app: user-service
  template:
    metadata:
      labels:
        app: user-service
    spec:
      containers:
      - name: node
        image: node:18-alpine
        command: ["node", "-e", "
          const http = require('http');
          const server = http.createServer((req, res) => {
            res.writeHead(200, {'Content-Type': 'text/plain'});
            res.end('User Service on 3000\\nPath: ' + req.url);
          });
          server.listen(3000, () => console.log('User service on 3000'));
        "]
        ports:
        - containerPort: 3000
---
apiVersion: v1
kind: Service
metadata:
  name: user-service
  namespace: practice-apps
spec:
  selector:
    app: user-service
  ports:
  - port: 3000
    targetPort: 3000
---
# Admin Panel
apiVersion: apps/v1
kind: Deployment
metadata:
  name: admin-panel
  namespace: practice-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: admin-panel
  template:
    metadata:
      labels:
        app: admin-panel
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 9000
---
apiVersion: v1
kind: Service
metadata:
  name: admin-panel
  namespace: practice-apps
spec:
  selector:
    app: admin-panel
  ports:
  - port: 9000
    targetPort: 9000
---
# Config Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: config-service
  namespace: practice-apps
spec:
  replicas: 1
  selector:
    matchLabels:
      app: config-service
  template:
    metadata:
      labels:
        app: config-service
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 4000
---
apiVersion: v1
kind: Service
metadata:
  name: config-service
  namespace: practice-apps
spec:
  selector:
    app: config-service
  ports:
  - port: 4000
    targetPort: 4000
EOF

echo "All applications deployed to namespace 'practice-apps'"
```

---

## **Question 1: Simple Host-Based Routing**

**Requirements:**
- `app.example.com` → `frontend-service:8080`
- `api.example.com` → `backend-service:3000`
- Use Gateway `main-gateway` on port 80

**Solution:**
```bash
# Create GatewayClass
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: traefik
spec:
  controllerName: traefik.io/gateway-controller
EOF

# Create Gateway
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: practice-apps
spec:
  gatewayClassName: traefik
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    hostname: "*.example.com"
EOF

# Create HTTPRoutes
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: app-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: main-gateway
    namespace: practice-apps
  hostnames:
  - "app.example.com"
  rules:
  - backendRefs:
    - name: frontend-service
      port: 8080
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: api-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: main-gateway
    namespace: practice-apps
  hostnames:
  - "api.example.com"
  rules:
  - backendRefs:
    - name: backend-service
      port: 3000
EOF

# Test
echo "Update /etc/hosts:"
echo "127.0.0.1 app.example.com"
echo "127.0.0.1 api.example.com"
echo ""
echo "Then test with:"
echo "curl -H 'Host: app.example.com' http://localhost"
echo "curl -H 'Host: api.example.com' http://localhost"
```

---

## **Question 2: Path Rewriting (API Gateway Pattern)**

**Requirements:**
- `/shop/products` → `product-service:8080` (receives `/products`)
- `/shop/cart` → `cart-service:9090` (receives `/cart`)
- `/auth/login` → `auth-service:7070` (receives `/login`)
- Single domain: `services.company.com`

**Solution:**
```bash
# Create HTTPRoute with URL rewrites
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: services-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: main-gateway
    namespace: practice-apps
  hostnames:
  - "services.company.com"
  rules:
  # /shop/products → /products
  - matches:
    - path:
        type: PathPrefix
        value: /shop/products
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /products
    backendRefs:
    - name: product-service
      port: 8080
  
  # /shop/cart → /cart
  - matches:
    - path:
        type: PathPrefix
        value: /shop/cart
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /cart
    backendRefs:
    - name: cart-service
      port: 9090
  
  # /auth/login → /login
  - matches:
    - path:
        type: PathPrefix
        value: /auth/login
    filters:
    - type: URLRewrite
      urlRewrite:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /login
    backendRefs:
    - name: auth-service
      port: 7070
EOF

# Test
echo "Update /etc/hosts:"
echo "127.0.0.1 services.company.com"
echo ""
echo "Test with:"
echo "curl -H 'Host: services.company.com' http://localhost/shop/products"
echo "curl -H 'Host: services.company.com' http://localhost/shop/cart"
echo "curl -H 'Host: services.company.com' http://localhost/auth/login"
```

---

## **Question 3: Path Redirects (Migration)**

**Requirements:**
- `/old/dashboard` → redirect to `/new/dashboard` (301 permanent)
- `/old/api/v1` → redirect to `/api/v2` (301 permanent)  
- `/temp/redirect` → redirect to `/new/temp` (302 temporary)
- Domain: `redirect.example.com`

**Solution:**
```bash
# Create HTTPRoute with redirects
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: redirect-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: main-gateway
    namespace: practice-apps
  hostnames:
  - "redirect.example.com"
  rules:
  # Permanent redirect: /old/dashboard → /new/dashboard
  - matches:
    - path:
        type: PathPrefix
        value: /old/dashboard
    filters:
    - type: RequestRedirect
      requestRedirect:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /new/dashboard
        statusCode: 301
  
  # Permanent redirect: /old/api/v1 → /api/v2
  - matches:
    - path:
        type: PathPrefix
        value: /old/api/v1
    filters:
    - type: RequestRedirect
      requestRedirect:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /api/v2
        statusCode: 301
  
  # Temporary redirect: /temp/redirect → /new/temp
  - matches:
    - path:
        type: PathPrefix
        value: /temp/redirect
    filters:
    - type: RequestRedirect
      requestRedirect:
        path:
          type: ReplacePrefixMatch
          replacePrefixMatch: /new/temp
        statusCode: 302
  
  # Default route (if no redirect matches)
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-service
      port: 8080
EOF

# Test
echo "Update /etc/hosts:"
echo "127.0.0.1 redirect.example.com"
echo ""
echo "Test redirects (use -v to see status codes):"
echo "curl -v -H 'Host: redirect.example.com' http://localhost/old/dashboard"
echo "curl -v -H 'Host: redirect.example.com' http://localhost/old/api/v1"
echo "curl -v -H 'Host: redirect.example.com' http://localhost/temp/redirect"
```

---

## **Question 4: TLS Configuration with Multiple Hostnames**

**Requirements:**
1. Configure TLS with certificate secret `wildcard-tls`
2. Route `app.company.com` and `api.company.com` to respective services
3. HTTPS only (no HTTP)

**Solution:**
```bash
# First create a test TLS certificate (self-signed for practice)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=*.company.com" -addext "subjectAltName=DNS:*.company.com"

# Create TLS secret
kubectl create secret tls wildcard-tls \
  --namespace=practice-apps \
  --cert=tls.crt \
  --key=tls.key

# Update Gateway with HTTPS listener
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: secure-gateway
  namespace: practice-apps
spec:
  gatewayClassName: traefik
  listeners:
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "*.company.com"
    tls:
      mode: Terminate
      certificateRefs:
      - name: wildcard-tls
EOF

# Create HTTPRoutes for HTTPS
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-app-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: secure-gateway
    namespace: practice-apps
    sectionName: https
  hostnames:
  - "app.company.com"
  rules:
  - backendRefs:
    - name: frontend-service
      port: 8080
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-api-route
  namespace: practice-apps
spec:
  parentRefs:
  - name: secure-gateway
    namespace: practice-apps
    sectionName: https
  hostnames:
  - "api.company.com"
  rules:
  - backendRefs:
    - name: backend-service
      port: 3000
EOF

# Test
echo "Update /etc/hosts:"
echo "127.0.0.1 app.company.com"
echo "127.0.0.1 api.company.com"
echo ""
echo "Port forward the HTTPS gateway:"
echo "kubectl -n practice-apps port-forward svc/secure-gateway 443"
echo ""
echo "Test HTTPS (use -k to ignore self-signed cert):"
echo "curl -k -H 'Host: app.company.com' https://localhost"
echo "curl -k -H 'Host: api.company.com' https://localhost"
```

---

## **Question 5: Exact vs Prefix Path Matching**

**Requirements:**
- `/api/health` (exact) → `health-check:8080`
- `/api/users` (prefix) → `user-service:3000`
- `/admin` (exact) → `admin-panel:9000`
- `/admin/config` (exact) → `config-service:4000` (higher priority)
- Domain: `mixed.example.com`

**Solution:**
```bash
# Create HTTPRoute with mixed path matching
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: mixed-routes
  namespace: practice-apps
spec:
  parentRefs:
  - name: main-gateway
    namespace: practice-apps
  hostnames:
  - "mixed.example.com"
  rules:
  # Highest priority: Exact matches first
  # /admin/config (exact)
  - matches:
    - path:
        type: Exact
        value: /admin/config
    backendRefs:
    - name: config-service
      port: 4000
  
  # /admin (exact)
  - matches:
    - path:
        type: Exact
        value: /admin
    backendRefs:
    - name: admin-panel
      port: 9000
  
  # /api/health (exact)
  - matches:
    - path:
        type: Exact
        value: /api/health
    backendRefs:
    - name: health-check
      port: 8080
  
  # /api/users (prefix) - matches /api/users, /api/users/123, etc.
  - matches:
    - path:
        type: PathPrefix
        value: /api/users
    backendRefs:
    - name: user-service
      port: 3000
  
  # Default catch-all
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: frontend-service
      port: 8080
EOF

# Test
echo "Update /etc/hosts:"
echo "127.0.0.1 mixed.example.com"
echo ""
echo "Test different path matches:"
echo "curl -H 'Host: mixed.example.com' http://localhost/api/health"
echo "curl -H 'Host: mixed.example.com' http://localhost/api/users"
echo "curl -H 'Host: mixed.example.com' http://localhost/api/users/123"
echo "curl -H 'Host: mixed.example.com' http://localhost/admin"
echo "curl -H 'Host: mixed.example.com' http://localhost/admin/config"
echo "curl -H 'Host: mixed.example.com' http://localhost/anything"
```

---

## **Complete Testing Script**
```bash
#!/bin/bash

echo "=== Testing Question 1: Host-Based Routing ==="
curl -s -H 'Host: app.example.com' http://localhost | head -2
curl -s -H 'Host: api.example.com' http://localhost | head -2
echo ""

echo "=== Testing Question 2: Path Rewriting ==="
curl -s -H 'Host: services.company.com' http://localhost/shop/products | head -2
curl -s -H 'Host: services.company.com' http://localhost/shop/cart | head -2
curl -s -H 'Host: services.company.com' http://localhost/auth/login | head -2
echo ""

echo "=== Testing Question 3: Path Redirects ==="
echo "Testing /old/dashboard (should redirect):"
curl -I -H 'Host: redirect.example.com' http://localhost/old/dashboard 2>/dev/null | grep HTTP
echo "Testing /temp/redirect (should redirect):"
curl -I -H 'Host: redirect.example.com' http://localhost/temp/redirect 2>/dev/null | grep HTTP
echo ""

echo "=== Testing Question 4: TLS (requires port 443 forwarding) ==="
echo "To test TLS, run: kubectl -n practice-apps port-forward svc/secure-gateway 443"
echo "Then: curl -k -H 'Host: app.company.com' https://localhost"
echo ""

echo "=== Testing Question 5: Exact vs Prefix ==="
echo "Exact match /api/health:"
curl -s -H 'Host: mixed.example.com' http://localhost/api/health
echo "Prefix match /api/users/123:"
curl -s -H 'Host: mixed.example.com' http://localhost/api/users/123
echo "Exact /admin/config (higher priority than /admin):"
curl -s -H 'Host: mixed.example.com' http://localhost/admin/config
```

---

## **Cleanup Script**
```bash
#!/bin/bash

# Delete all resources
kubectl delete namespace practice-apps
kubectl delete gatewayclass traefik

# Delete TLS files
rm -f tls.key tls.crt

# Delete cluster
kind delete cluster --name gateway-practice

echo "All resources cleaned up"
```

**Note:** This creates a complete working environment with all applications, Gateways, and HTTPRoutes. Each question has its own solution that you can test independently.