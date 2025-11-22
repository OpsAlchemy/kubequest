Here's a comprehensive documentation of all the Nginx Ingress annotations used in the scenarios:

## Nginx Ingress Annotations Documentation

### 1. **Basic Routing Annotations**
```yaml
# Ingress class specification
kubernetes.io/ingress.class: "nginx"

# Alternative ingress class specification
nginx.ingress.kubernetes.io/ingress-class: "nginx"
```

### 2. **SSL/TLS Annotations**
```yaml
# Force SSL redirect
nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

# SSL protocol (default: TLSv1 TLSv1.1 TLSv1.2 TLSv1.3)
nginx.ingress.kubernetes.io/ssl-protocols: "TLSv1.2 TLSv1.3"

# SSL ciphers
nginx.ingress.kubernetes.io/ssl-ciphers: "HIGH:!aNULL:!MD5"

# SSL session tickets
nginx.ingress.kubernetes.io/ssl-session-tickets: "true"
```

### 3. **Rate Limiting Annotations**
```yaml
# Requests per second per IP
nginx.ingress.kubernetes.io/limit-rps: "100"

# Requests per minute per IP
nginx.ingress.kubernetes.io/limit-rpm: "1000"

# Rate limit burst (number of excessive requests)
nginx.ingress.kubernetes.io/limit-burst: "50"

# Rate limit key (default: $binary_remote_addr)
nginx.ingress.kubernetes.io/limit-whitelist: "cidr"
```

### 4. **Canary Deployment Annotations**
```yaml
# Enable canary
nginx.ingress.kubernetes.io/canary: "true"

# Traffic weight (0-100)
nginx.ingress.kubernetes.io/canary-weight: "20"

# Canary by header
nginx.ingress.kubernetes.io/canary-by-header: "canary"

# Canary by header value
nginx.ingress.kubernetes.io/canary-by-header-value: "always"

# Canary by cookie
nginx.ingress.kubernetes.io/canary-by-cookie: "canary"
```

### 5. **Rewrite Rules Annotations**
```yaml
# Rewrite target path
nginx.ingress.kubernetes.io/rewrite-target: "/$2"

# Enable regex in paths
nginx.ingress.kubernetes.io/use-regex: "true"

# Server-side includes
nginx.ingress.kubernetes.io/ssi: "true"

# Subrequest output buffer size
nginx.ingress.kubernetes.io/ssi-buffer-size: "64k"
```

### 6. **Load Balancing Annotations**
```yaml
# Load balancing algorithm
nginx.ingress.kubernetes.io/load-balance: "round_robin"
# Options: round_robin, least_conn, ip_hash, hash, random

# Session affinity (sticky sessions)
nginx.ingress.kubernetes.io/affinity: "cookie"
nginx.ingress.kubernetes.io/session-cookie-name: "route"
nginx.ingress.kubernetes.io/session-cookie-expires: "172800"
nginx.ingress.kubernetes.io/session-cookie-max-age: "172800"

# Consistent hashing
nginx.ingress.kubernetes.io/upstream-hash-by: "$request_uri"
# Variables: $remote_addr, $request_uri, $host, etc.
```

### 7. **Backend Protocol Annotations**
```yaml
# Backend protocol
nginx.ingress.kubernetes.io/backend-protocol: "GRPC"
# Options: HTTP, HTTPS, GRPC, GRPCS

# GRPC read timeout
nginx.ingress.kubernetes.io/grpc-read-timeout: "30s"

# GRPC send timeout
nginx.ingress.kubernetes.io/grpc-send-timeout: "30s"
```

### 8. **Proxy and Timeout Annotations**
```yaml
# Proxy read timeout
nginx.ingress.kubernetes.io/proxy-read-timeout: "60"

# Proxy connect timeout
nginx.ingress.kubernetes.io/proxy-connect-timeout: "60"

# Proxy send timeout
nginx.ingress.kubernetes.io/proxy-send-timeout: "60"

# Proxy buffer size
nginx.ingress.kubernetes.io/proxy-buffer-size: "8k"

# Proxy buffers number
nginx.ingress.kubernetes.io/proxy-buffers-number: "4"

# Proxy next upstream
nginx.ingress.kubernetes.io/proxy-next-upstream: "error timeout"
```

### 9. **CORS Annotations**
```yaml
# Enable CORS
nginx.ingress.kubernetes.io/enable-cors: "true"

# CORS methods
nginx.ingress.kubernetes.io/cors-allow-methods: "PUT, GET, POST, OPTIONS"

# CORS headers
nginx.ingress.kubernetes.io/cors-allow-headers: "DNT,Keep-Alive,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Authorization"

# CORS origin
nginx.ingress.kubernetes.io/cors-allow-origin: "*"

# CORS credentials
nginx.ingress.kubernetes.io/cors-allow-credentials: "true"
```

### 10. **Authentication Annotations**
```yaml
# Basic auth
nginx.ingress.kubernetes.io/auth-type: "basic"
nginx.ingress.kubernetes.io/auth-secret: "basic-auth"
nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"

# External auth
nginx.ingress.kubernetes.io/auth-url: "http://auth-service.default.svc.cluster.local/auth"
nginx.ingress.kubernetes.io/auth-method: "GET"
nginx.ingress.kubernetes.io/auth-response-headers: "Authorization, Set-Cookie"
```

### 11. **IP Restriction Annotations**
```yaml
# Whitelist source range
nginx.ingress.kubernetes.io/whitelist-source-range: "192.168.0.0/16, 10.0.0.0/8"

# Denylist source range
nginx.ingress.kubernetes.io/denylist-source-range: "1.2.3.4/32"

# Satisfy any (whitelist OR auth)
nginx.ingress.kubernetes.io/satisfy: "any"
```

### 12. **Error Handling Annotations**
```yaml
# Custom HTTP errors
nginx.ingress.kubernetes.io/custom-http-errors: "404,500,503"

# Default backend
nginx.ingress.kubernetes.io/default-backend: "default-http-backend"

# Custom default backend
nginx.ingress.kubernetes.io/custom-default-backend: "true"

# Configuration snippet for error pages
nginx.ingress.kubernetes.io/configuration-snippet: |
  error_page 404 /custom_404.html;
  location = /custom_404.html {
    root /usr/share/nginx/html;
    internal;
  }
```

### 13. **Logging Annotations**
```yaml
# Enable access log
nginx.ingress.kubernetes.io/enable-access-log: "true"

# Access log path
nginx.ingress.kubernetes.io/access-log-path: "/var/log/nginx/access.log"

# Error log path
nginx.ingress.kubernetes.io/error-log-path: "/var/log/nginx/error.log"

# Log format
nginx.ingress.kubernetes.io/log-format: '$remote_addr - $remote_user [$time_local] "$request" $status $body_bytes_sent "$http_referer" "$http_user_agent"'
```

### 14. **Server-Side Includes (SSI)**
```yaml
# Enable SSI
nginx.ingress.kubernetes.io/ssi: "true"

# SSI buffer size
nginx.ingress.kubernetes.io/ssi-buffer-size: "64k"

# SSI types
nginx.ingress.kubernetes.io/ssi-types: "text/shtml"
```

### 15. **Miscellaneous Annotations**
```yaml
# Client body buffer size
nginx.ingress.kubernetes.io/client-body-buffer-size: "8k"

# Client max body size
nginx.ingress.kubernetes.io/client-max-body-size: "1m"

# Proxy body size
nginx.ingress.kubernetes.io/proxy-body-size: "1m"

# Server tokens (show/hide nginx version)
nginx.ingress.kubernetes.io/server-tokens: "false"

# Server snippets
nginx.ingress.kubernetes.io/server-snippet: |
  add_header X-Custom-Header "value";
  more_set_headers "Server: custom";

# Configuration snippets
nginx.ingress.kubernetes.io/configuration-snippet: |
  more_set_headers "X-Custom-Header: value";

# Location snippets
nginx.ingress.kubernetes.io/location-snippet: |
  proxy_set_header X-Custom-Header "value";
```

### 16. **gRPC Specific Annotations**
```yaml
# gRPC backend protocol
nginx.ingress.kubernetes.io/backend-protocol: "GRPC"

# gRPC read timeout
nginx.ingress.kubernetes.io/grpc-read-timeout: "30s"

# gRPC send timeout
nginx.ingress.kubernetes.io/grpc-send-timeout: "30s"
```

### 17. **WebSocket Annotations**
```yaml
# Enable WebSocket
nginx.ingress.kubernetes.io/websocket-services: "ws-svc"

# WebSocket read timeout
nginx.ingress.kubernetes.io/websocket-read-timeout: "3600"

# WebSocket send timeout
nginx.ingress.kubernetes.io/websocket-send-timeout: "3600"
```

## Usage Examples

### Basic Ingress with Annotations:
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: "/$2"
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/limit-rps: "100"
spec:
  ingressClassName: nginx
  rules:
  - host: example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: api-service
            port:
              number: 80
```

This comprehensive documentation covers all the major Nginx Ingress annotations used across the various scenarios you provided.