# NGINX Ingress Controller Practice Solutions

## **Setup First (Run This)**
```bash
#!/bin/bash

# Create cluster
kind create cluster --name nginx-practice --image kindest/node:v1.28.0

# Install NGINX Ingress Controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

# Wait for NGINX to be ready
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s

# Deploy all test applications (same as Gateway API setup)
kubectl apply -f - <<EOF
apiVersion: v1
kind: Namespace
metadata:
  name: nginx-practice-apps
---
# Frontend Service
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
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
  namespace: nginx-practice-apps
spec:
  selector:
    app: config-service
  ports:
  - port: 4000
    targetPort: 4000
EOF

echo "Setup complete. NGINX Ingress and applications deployed."
```

---

## **Question 1 Solution: Simple Host-Based Routing with NGINX Ingress**

```yaml
# 1-host-based-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-based-ingress
  namespace: nginx-practice-apps
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 8080
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3000
```

**Apply and test:**
```bash
kubectl apply -f 1-host-based-ingress.yaml

# Update hosts file
echo "127.0.0.1 app.example.com" | sudo tee -a /etc/hosts
echo "127.0.0.1 api.example.com" | sudo tee -a /etc/hosts

# Port forward NGINX
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 80:80

# Test
curl -H "Host: app.example.com" http://localhost
curl -H "Host: api.example.com" http://localhost
```

---

## **Question 2 Solution: Path Rewriting with NGINX Annotations**

```yaml
# 2-path-rewrite-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-rewrite-ingress
  namespace: nginx-practice-apps
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  ingressClassName: nginx
  rules:
  - host: services.company.com
    http:
      paths:
      # /shop/products → /products
      - path: /shop/products(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: product-service
            port:
              number: 8080
      
      # /shop/cart → /cart
      - path: /shop/cart(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: cart-service
            port:
              number: 9090
      
      # /auth/login → /login
      - path: /auth/login(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: auth-service
            port:
              number: 7070
```

**Apply and test:**
```bash
kubectl apply -f 2-path-rewrite-ingress.yaml

echo "127.0.0.1 services.company.com" | sudo tee -a /etc/hosts

curl -H "Host: services.company.com" http://localhost/shop/products
curl -H "Host: services.company.com" http://localhost/shop/cart
curl -H "Host: services.company.com" http://localhost/auth/login
```

---

## **Question 3 Solution: Path Redirects with NGINX Configuration**

```yaml
# 3-redirect-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: redirect-ingress
  namespace: nginx-practice-apps
  annotations:
    # Permanent redirect for /old/dashboard
    nginx.ingress.kubernetes.io/permanent-redirect: /new/dashboard
    nginx.ingress.kubernetes.io/permanent-redirect-code: "301"
    # Temporary redirect for /temp/redirect
    nginx.ingress.kubernetes.io/temporary-redirect: /new/temp
    # Configuration snippet for custom redirects
    nginx.ingress.kubernetes.io/configuration-snippet: |
      location ~ ^/old/api/v1(/|$)(.*) {
        return 301 /api/v2/$2;
      }
spec:
  ingressClassName: nginx
  rules:
  - host: redirect.example.com
    http:
      paths:
      # This path triggers the permanent-redirect annotation
      - path: /old/dashboard
        pathType: Prefix
        backend:
          service:
            name: frontend-service  # Dummy backend
            port:
              number: 8080
      
      # This path triggers the temporary-redirect annotation
      - path: /temp/redirect
        pathType: Prefix
        backend:
          service:
            name: frontend-service  # Dummy backend
            port:
              number: 8080
      
      # Default route for other paths
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 8080
```

**Apply and test:**
```bash
kubectl apply -f 3-redirect-ingress.yaml

echo "127.0.0.1 redirect.example.com" | sudo tee -a /etc/hosts

# Test redirects
curl -v -H "Host: redirect.example.com" http://localhost/old/dashboard
curl -v -H "Host: redirect.example.com" http://localhost/old/api/v1
curl -v -H "Host: redirect.example.com" http://localhost/temp/redirect
```

---

## **Question 4 Solution: TLS Configuration with NGINX Ingress**

```bash
# First create TLS certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout tls.key -out tls.crt \
  -subj "/CN=*.company.com" -addext "subjectAltName=DNS:*.company.com,DNS:app.company.com,DNS:api.company.com"

# Create TLS secret
kubectl create secret tls wildcard-tls \
  --namespace=nginx-practice-apps \
  --cert=tls.crt \
  --key=tls.key
```

```yaml
# 4-tls-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
  namespace: nginx-practice-apps
  annotations:
    # Force SSL redirect
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
    # SSL protocols
    nginx.ingress.kubernetes.io/ssl-protocols: "TLSv1.2 TLSv1.3"
    # SSL ciphers
    nginx.ingress.kubernetes.io/ssl-ciphers: "ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384"
spec:
  ingressClassName: nginx
  tls:
  - hosts:
    - app.company.com
    - api.company.com
    secretName: wildcard-tls
  rules:
  - host: app.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 8080
  - host: api.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: backend-service
            port:
              number: 3000
```

**Apply and test:**
```bash
kubectl apply -f 4-tls-ingress.yaml

echo "127.0.0.1 app.company.com" | sudo tee -a /etc/hosts
echo "127.0.0.1 api.company.com" | sudo tee -a /etc/hosts

# Port forward HTTPS (443)
kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443

# Test HTTPS (self-signed cert, use -k)
curl -k -H "Host: app.company.com" https://localhost
curl -k -H "Host: api.company.com" https://localhost

# Test HTTP redirect to HTTPS
curl -v -H "Host: app.company.com" http://localhost
# Should get 308 redirect to https
```

---

## **Question 5 Solution: Exact vs Prefix Path Matching with NGINX**

```yaml
# 5-path-matching-ingress.yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-matching-ingress
  namespace: nginx-practice-apps
spec:
  ingressClassName: nginx
  rules:
  - host: mixed.example.com
    http:
      paths:
      # Exact match: /admin/config (highest priority)
      - path: /admin/config
        pathType: Exact
        backend:
          service:
            name: config-service
            port:
              number: 4000
      
      # Exact match: /admin
      - path: /admin
        pathType: Exact
        backend:
          service:
            name: admin-panel
            port:
              number: 9000
      
      # Exact match: /api/health
      - path: /api/health
        pathType: Exact
        backend:
          service:
            name: health-check
            port:
              number: 8080
      
      # Prefix match: /api/users (matches /api/users/*)
      - path: /api/users
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 3000
      
      # Default catch-all
      - path: /
        pathType: Prefix
        backend:
          service:
            name: frontend-service
            port:
              number: 8080
```

**Apply and test:**
```bash
kubectl apply -f 5-path-matching-ingress.yaml

echo "127.0.0.1 mixed.example.com" | sudo tee -a /etc/hosts

# Test exact matches
echo "Exact /api/health:"
curl -H "Host: mixed.example.com" http://localhost/api/health
echo ""

echo "Prefix /api/users/123:"
curl -H "Host: mixed.example.com" http://localhost/api/users/123
echo ""

echo "Exact /admin/config (should NOT match /admin):"
curl -H "Host: mixed.example.com" http://localhost/admin/config
echo ""

echo "Exact /admin (different from /admin/config):"
curl -H "Host: mixed.example.com" http://localhost/admin
echo ""

echo "Non-matching path (should go to default):"
curl -H "Host: mixed.example.com" http://localhost/anything
```

---

## **Complete Testing Script**
```bash
#!/bin/bash

echo "=== Testing NGINX Ingress Solutions ==="
echo ""

echo "1. Testing Host-Based Routing:"
curl -s -H "Host: app.example.com" http://localhost | head -2
curl -s -H "Host: api.example.com" http://localhost | head -2
echo ""

echo "2. Testing Path Rewriting:"
echo "/shop/products → /products:"
curl -s -H "Host: services.company.com" http://localhost/shop/products | head -2
echo "/auth/login → /login:"
curl -s -H "Host: services.company.com" http://localhost/auth/login | head -2
echo ""

echo "3. Testing Redirects:"
echo "/old/dashboard (should 301 redirect):"
curl -I -H "Host: redirect.example.com" http://localhost/old/dashboard 2>/dev/null | grep HTTP
echo "/temp/redirect (should 302 redirect):"
curl -I -H "Host: redirect.example.com" http://localhost/temp/redirect 2>/dev/null | grep HTTP
echo ""

echo "4. Testing TLS (requires port 443):"
echo "Run: kubectl port-forward -n ingress-nginx svc/ingress-nginx-controller 443:443"
echo "Then: curl -k -H 'Host: app.company.com' https://localhost"
echo ""

echo "5. Testing Path Matching:"
echo "Exact /api/health:"
curl -s -H "Host: mixed.example.com" http://localhost/api/health
echo "Prefix /api/users/123:"
curl -s -H "Host: mixed.example.com" http://localhost/api/users/123
echo "Exact /admin/config:"
curl -s -H "Host: mixed.example.com" http://localhost/admin/config
```

---

## **Key Differences: NGINX Ingress vs Gateway API**

| Feature | NGINX Ingress | Gateway API |
|---------|--------------|-------------|
| **Path Rewriting** | Annotations: `rewrite-target`, `use-regex` | Native: `URLRewrite` filter |
| **Redirects** | Annotations: `permanent-redirect`, `temporary-redirect` | Native: `RequestRedirect` filter |
| **TLS** | `tls` section + annotations | `tls` in Gateway listeners |
| **Path Matching** | `pathType: Exact/Prefix/ImplementationSpecific` | `type: Exact/PathPrefix/RegularExpression` |
| **Priority** | Order in YAML + pathType specificity | Rule order in HTTPRoute |

**Note:** NGINX Ingress uses annotations heavily, while Gateway API has native fields for these features.