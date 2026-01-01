# NGINX Configs that Mimic Kubernetes Ingress Behavior

## 🎯 **INGRESS PATTERN → PURE NGINX CONFIG MAPPING**

### **1. Basic Path Routing (Prefix Match)**

**K8s Ingress Pattern:**
```yaml
path: /api
pathType: Prefix
backend:
  service:
    name: api-service
    port: 80
```

**Equivalent NGINX Config (Standalone VM):**
```nginx
server {
    listen 80;
    server_name example.com;
    
    # Prefix match - all paths starting with /api
    location /api {
        # Equivalent to K8s Service ClusterIP
        proxy_pass http://192.168.1.100:8080;  # Your backend server IP:Port
        
        # Standard proxy headers (added automatically in K8s)
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

---

### **2. Exact Match vs Prefix Match**

**K8s Ingress:**
```yaml
paths:
- path: /login
  pathType: Exact      # Only /login
  backend: auth-service
- path: /api
  pathType: Prefix     # /api and /api/*
  backend: api-service
```

**NGINX Equivalent:**
```nginx
server {
    listen 80;
    server_name example.com;
    
    # Exact match (=) - Only /login
    location = /login {
        proxy_pass http://192.168.1.101:3000;
    }
    
    # Prefix match - /api and anything under it
    location /api {
        proxy_pass http://192.168.1.102:8080;
        
        # IMPORTANT: Add trailing slash or not?
        # With slash: /api/users → backend sees /users
        # Without slash: /api/users → backend sees /api/users
        # proxy_pass http://192.168.1.102:8080/;  # With slash strips /api
    }
}
```

---

### **3. Rewrite-Target Pattern**

**K8s Ingress with Rewrite:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /$2
paths:
- path: /api/v1(/|$)(.*)
  pathType: Prefix
```

**NGINX Equivalent (Manual):**
```nginx
server {
    listen 80;
    server_name example.com;
    
    location ~ ^/api/v1(/|$)(.*) {
        # Capture the path after /api/v1
        set $captured_path $2;
        
        # Rewrite to remove /api/v1 prefix
        rewrite ^/api/v1(/|$)(.*) /$captured_path break;
        
        proxy_pass http://192.168.1.103:8080;
    }
}
```

**Simpler NGINX version (using proxy_pass cleverly):**
```nginx
server {
    listen 80;
    server_name example.com;
    
    location /api/v1 {
        # The trailing slash in proxy_pass strips /api/v1
        proxy_pass http://192.168.1.103:8080/;
    }
}
```

---

### **4. Multiple Hostnames (Virtual Hosts)**

**K8s Ingress:**
```yaml
rules:
- host: api.example.com
  http:
    paths:
    - path: /
      backend: api-service
- host: app.example.com
  http:
    paths:
    - path: /
      backend: app-service
```

**NGINX Equivalent:**
```nginx
# First virtual host - API
server {
    listen 80;
    server_name api.example.com;
    
    location / {
        proxy_pass http://192.168.1.100:8080;
    }
}

# Second virtual host - App
server {
    listen 80;
    server_name app.example.com;
    
    location / {
        proxy_pass http://192.168.1.101:3000;
    }
}

# Default/Catch-all server block
server {
    listen 80 default_server;
    server_name _;  # Matches any host
    
    return 404;  # Or serve a default page
}
```

---

### **5. Path-based Routing with Priority**

**K8s Ingress (Priority: Exact > Longer Prefix > Shorter Prefix):**
```yaml
paths:
- path: /api/users/login
  pathType: Exact      # Highest priority
  backend: auth-service
- path: /api/users
  pathType: Prefix     # Medium priority
  backend: user-service
- path: /api
  pathType: Prefix     # Lowest priority
  backend: api-service
```

**NGINX Equivalent (Order matters!):**
```nginx
server {
    listen 80;
    server_name example.com;
    
    # 1. Exact match - Highest priority
    location = /api/users/login {
        proxy_pass http://192.168.1.100:3000;
    }
    
    # 2. More specific prefix
    location /api/users {
        proxy_pass http://192.168.1.101:8080/;  # Strips /api/users
    }
    
    # 3. Less specific prefix - MUST come last
    location /api {
        proxy_pass http://192.168.1.102:9000/;  # Strips /api
    }
    
    # 4. Catch-all (if needed)
    location / {
        proxy_pass http://192.168.1.103:80;
    }
}
```

---

### **6. Regex Path Matching**

**K8s Ingress:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/use-regex: "true"
paths:
- path: ^/v[0-9]+/users/[0-9]+$
  pathType: ImplementationSpecific
```

**NGINX Equivalent:**
```nginx
server {
    listen 80;
    server_name example.com;
    
    # Case-sensitive regex (~)
    location ~ ^/v[0-9]+/users/[0-9]+$ {
        proxy_pass http://192.168.1.100:8080;
    }
    
    # Case-insensitive regex (~*)
    location ~* ^/api/v[0-9]+/(users|products)$ {
        proxy_pass http://192.168.1.101:3000;
    }
}
```

---

### **7. Rewrite with Capture Groups**

**K8s Ingress:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /v2/$2/$1
paths:
- path: /old/v1/([^/]+)/([^/]+)
  pathType: ImplementationSpecific
```

**NGINX Equivalent:**
```nginx
server {
    listen 80;
    server_name example.com;
    
    location ~ ^/old/v1/([^/]+)/([^/]+) {
        # $1 = first capture group, $2 = second capture group
        rewrite ^/old/v1/([^/]+)/([^/]+) /v2/$2/$1 break;
        proxy_pass http://192.168.1.100:8080;
    }
}
```

---

### **8. Redirects (301/302)**

**K8s Ingress:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/permanent-redirect: "https://new.example.com"
```

**NGINX Equivalent:**
```nginx
server {
    listen 80;
    server_name old.example.com;
    
    # Permanent redirect (301)
    location / {
        return 301 https://new.example.com$request_uri;
    }
}

# Or for temporary redirect (302)
server {
    listen 80;
    server_name temp.example.com;
    
    location / {
        return 302 https://temporary.example.com$request_uri;
    }
}
```

---

### **9. SSL/TLS Termination + HTTP→HTTPS Redirect**

**K8s Ingress:**
```yaml
tls:
- hosts:
  - example.com
  secretName: example-tls
annotations:
  nginx.ingress.kubernetes.io/ssl-redirect: "true"
```

**NGINX Equivalent:**
```nginx
# HTTP server - redirect to HTTPS
server {
    listen 80;
    server_name example.com;
    
    # Permanent redirect to HTTPS
    return 301 https://$server_name$request_uri;
}

# HTTPS server - actual service
server {
    listen 443 ssl;
    server_name example.com;
    
    # SSL certificates (like K8s secrets)
    ssl_certificate /etc/nginx/ssl/example.com.crt;
    ssl_certificate_key /etc/nginx/ssl/example.com.key;
    
    location / {
        proxy_pass http://192.168.1.100:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-Proto https;
    }
}
```

---

### **10. Rate Limiting**

**K8s Ingress:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/limit-rps: "10"
  nginx.ingress.kubernetes.io/limit-whitelist: "10.0.0.0/8"
```

**NGINX Equivalent:**
```nginx
# Define limit zone (like K8s annotation)
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

server {
    listen 80;
    server_name api.example.com;
    
    # Whitelist IPs
    geo $limit {
        default 1;
        10.0.0.0/8 0;  # Whitelisted
    }
    
    map $limit $limit_key {
        0 "";
        1 $binary_remote_addr;
    }
    
    location /api {
        # Apply rate limiting
        limit_req zone=api_limit burst=20;
        
        # Only apply to non-whitelisted IPs
        limit_req zone=api_limit burst=20;
        
        proxy_pass http://192.168.1.100:8080;
    }
}
```

---

## 🚀 **COMPLETE NGINX TEMPLATE MIMICKING K8S INGRESS**

Here's a complete NGINX config that replicates common K8s Ingress patterns:

```nginx
# multi-service-nginx.conf
# Equivalent to having multiple Ingress resources in K8s

# Global rate limiting (like K8s annotation)
limit_req_zone $binary_remote_addr zone=global_limit:10m rate=100r/s;

# API Service - like api.example.com in K8s
server {
    listen 80;
    server_name api.company.com;
    
    # Rate limiting per location
    limit_req zone=global_limit burst=50;
    
    # Exact match endpoint
    location = /api/auth/login {
        proxy_pass http://192.168.1.100:3000;
    }
    
    # Versioned API with rewrite
    location /api/v1 {
        # Strip /api/v1 prefix (like rewrite-target: /$2)
        proxy_pass http://192.168.1.101:8080/;
    }
    
    # Regex pattern matching
    location ~ ^/api/users/([0-9]+)/profile$ {
        proxy_pass http://192.168.1.102:4000;
    }
    
    # Catch-all for /api
    location /api {
        proxy_pass http://192.168.1.103:8080;
    }
}

# Web App - like app.company.com in K8s
server {
    listen 80;
    server_name app.company.com;
    
    # SPA routing - serve index.html for all paths
    location / {
        root /var/www/app;
        try_files $uri $uri/ /index.html;
    }
    
    # Static assets
    location /static/ {
        root /var/www/app;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}

# Redirect old domain - like permanent-redirect annotation
server {
    listen 80;
    server_name old.company.com;
    
    return 301 https://app.company.com$request_uri;
}

# Default 404 for unmatched hosts
server {
    listen 80 default_server;
    server_name _;
    
    return 404 "Host not found";
}
```

---

## 📝 **QUICK REFERENCE: K8s → NGINX Translation Table**

| Kubernetes Ingress Concept | NGINX Equivalent | Notes |
|---------------------------|-----------------|-------|
| `host: api.example.com` | `server_name api.example.com;` | Virtual host configuration |
| `path: /api` + `pathType: Prefix` | `location /api { ... }` | Prefix matching |
| `path: /login` + `pathType: Exact` | `location = /login { ... }` | Exact matching |
| `rewrite-target: /$2` | `rewrite ^/prefix/(.*)$ /$1 break;` | Path rewriting |
| Multiple Ingress objects | Multiple `server {}` blocks | Each host = server block |
| `ssl-redirect: "true"` | `return 301 https://$host$request_uri;` | HTTP→HTTPS redirect |
| Backend Service | `proxy_pass http://backend_ip:port;` | Manual upstream definition |
| TLS Secret | `ssl_certificate` & `ssl_certificate_key` | Manual certificate management |
| `canary-weight: "20"` | `split_clients` or custom logic | Manual traffic splitting |

---

## 🎯 **KEY TAKEAWAYS:**

1. **Host-based routing** = Multiple `server {}` blocks
2. **Path-based routing** = Multiple `location {}` blocks
3. **Priority handling** = Order matters in NGINX config
4. **Rewrites** = Use `rewrite` directive or clever `proxy_pass` with trailing slash
5. **SSL/TLS** = Separate HTTP (redirect) and HTTPS (serve) server blocks
6. **No service discovery** = You must hardcode backend IPs or use DNS

**Pro Tip:** In standalone NGINX, you're responsible for:
- Backend service discovery (DNS or static IPs)
- Health checks (use `upstream` with health checks)
- Load balancing (configure `upstream` with multiple backends)
- Certificate management (manual cert renewal)