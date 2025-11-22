Here's the breakdown of what finally worked with the prefix implementation:

## The Working Ingress Configuration

**ingress.yaml**:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-demo-ingress
  namespace: playground
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-demo
            port:
              number: 5000
```

## Key Points That Made It Work:

### 1. **No rewrite-target annotation**
- **Problem**: Using `nginx.ingress.kubernetes.io/rewrite-target: /$2` was stripping the `/api` prefix
- **Solution**: Remove rewrite-target entirely - let the full path pass through

### 2. **Correct pathType: Prefix**
- **Problem**: Regex patterns like `/api(/|$)(.*)` don't work with `pathType: Prefix`
- **Solution**: Use simple `/api` path with `pathType: Prefix`

### 3. **How Prefix Matching Works:**
- `/api` with `pathType: Prefix` matches:
  - `/api` ✅
  - `/api/` ✅  
  - `/api/v1/users` ✅
  - `/api/v2/products` ✅
  - `/apisomething` ❌ (no trailing slash)
  - `/ap` ❌ (not a prefix match)

### 4. **Request Flow:**
```
Client: curl http://ingress-ip/api/v1/orders
↓
Ingress: matches /api prefix → forwards to service
↓
Service: routes to pod on port 5000  
↓
Pod: receives /api/v1/orders → Flask handles it
↓
Response: {"orders":["order1","order2"],"version":"v1"}
```

### 5. **Why the Previous Attempts Failed:**

**Attempt 1**: Regex with wrong pathType
```yaml
path: /api(/|$)(.*)
pathType: Prefix  # ❌ Regex not allowed with Prefix
```

**Attempt 2**: Rewrite-target stripping too much
```yaml
nginx.ingress.kubernetes.io/rewrite-target: /$2
# /api/v1/orders → /v1/orders → 404 (route doesn't exist)
```

**Attempt 3**: Correct implementation
```yaml
path: /api
pathType: Prefix
# No rewrite-target → /api/v1/orders → /api/v1/orders ✅
```

### 6. **When to Use Rewrite-Target:**
Only use rewrite-target if you want to:
- Remove a prefix: `/api/v1/orders` → `/v1/orders`  
- Change the path structure
- Your backend expects different URL patterns

### 7. **pathType Options:**
- **Prefix**: Matches based on URL prefix (what we used)
- **Exact**: Exact string match
- **ImplementationSpecific**: Depends on ingress controller

The key insight: **If your backend expects the full path including the prefix, don't use rewrite-target**. Let the ingress forward the complete path as-is.