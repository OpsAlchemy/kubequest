# NGINX Location Block Master Guide

## 🎯 **NGINX LOCATION BLOCKS: The Complete Pattern Reference**

### **1. Location Block Syntax Fundamentals**

```nginx
location [modifier] [uri_pattern] {
    # Configuration directives
}
```

---

## 📚 **MODIFIER TYPES & THEIR BEHAVIOR**

### **No Modifier = Prefix Match**
```nginx
location /api {
    # Matches: /api, /api/, /api/users, /api/v1/test
    # Does NOT match: /apix, /api-test
}
```

**Key Points:**
- **Longest prefix wins**: `/api/users` will match over `/api` if both exist
- **Case-sensitive by default**
- **Most commonly used**

---

### **`= ` Exact Match Modifier**
```nginx
location = /login {
    # Matches ONLY: /login
    # Does NOT match: /login/, /login/user, /LOGIN
    # Highest priority
}
```

**Use Case:** Login endpoints, specific static files, health checks

---

### **`~ ` Case-Sensitive Regex**
```nginx
location ~ \.(gif|jpg|png)$ {
    # Matches: /image.jpg, /data/photo.PNG
    # Case-sensitive: /image.JPG would NOT match
}
```

**Regex Examples:**
```nginx
# Match numeric user IDs
location ~ ^/users/[0-9]+$ {
    # /users/123 ✓
    # /users/abc ✗
}

# Complex pattern
location ~ ^/api/v[0-9]+/(create|update|delete)$ {
    # /api/v1/create ✓
    # /api/v2/update ✓
    # /api/v1/get ✗
}
```

---

### **`~* ` Case-Insensitive Regex**
```nginx
location ~* \.(gif|jpg|jpeg|png)$ {
    # Matches: /image.jpg, /IMAGE.JPG, /data/Photo.PNG
    # All case variations match
}
```

---

### **`^~ ` Non-Regex Prefix (Priority Prefix)**
```nginx
location ^~ /static {
    # Matches: /static, /static/, /static/css/style.css
    # Higher priority than regex locations
    # But still prefix-based matching
}
```

**Special Behavior:**  
Stops regex evaluation for this path - regex locations won't be checked if this matches.

---

## 🔄 **PRIORITY & EVALUATION ORDER**

### **NGINX Location Selection Algorithm:**

1. **Exact match (`=`) locations** - Checked first
2. **Non-regex prefix (`^~`) locations** - Checked second
3. **Regex locations (`~` and `~*`)** - Checked in order of appearance
4. **Regular prefix locations** - Longest prefix wins

```nginx
server {
    # 1. Checked first: Exact matches
    location = /api/login {
        # Highest priority if URL is exactly /api/login
    }
    
    # 2. Checked second: Non-regex prefix
    location ^~ /api {
        # Will match /api/users before any regex below
        # Prevents regex checks for /api paths
    }
    
    # 3. Checked in order: Regex matches
    location ~ \.php$ {
        # Matches .php files
    }
    
    location ~* \.(gif|jpg)$ {
        # Case-insensitive image files
    }
    
    # 4. Checked last: Regular prefix (longest wins)
    location /api/users {
        # Longer than /api, so wins for /api/users/*
    }
    
    location /api {
        # Shorter prefix, lower priority than /api/users
    }
}
```

---

## 🚀 **PRODUCTION PATTERNS & EXAMPLES**

### **Pattern 1: Static File Serving with Cache Control**
```nginx
location ~* \.(css|js|jpg|jpeg|png|gif|ico|woff|woff2|ttf|svg)$ {
    root /var/www/static;
    expires 1y;  # Browser cache for 1 year
    add_header Cache-Control "public, immutable";
    
    # Gzip compression
    gzip_static on;
    gzip_types text/css application/javascript;
    
    # Security headers
    add_header X-Content-Type-Options "nosniff";
}
```

### **Pattern 2: API Gateway with Versioning**
```nginx
# Exact endpoints first
location = /api/v1/auth/login {
    proxy_pass http://auth-service:3000;
}

location = /api/v1/auth/logout {
    proxy_pass http://auth-service:3000;
}

# Version-specific routing with rewrite
location ~ ^/api/v1/(users|products|orders) {
    # Strip /api/v1 prefix
    set $service_name $1;
    rewrite ^/api/v1/(users|products|orders)/(.*) /$2 break;
    proxy_pass http://$service_name-service:8080;
}

# Catch-all for v1 API
location /api/v1 {
    proxy_pass http://api-gateway:8080/;
}

# New API version
location /api/v2 {
    proxy_pass http://api-v2-gateway:9090/;
}
```

### **Pattern 3: Single Page Application (SPA) Routing**
```nginx
# Static assets with cache
location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
    root /var/www/app;
    expires 1y;
    add_header Cache-Control "public, immutable";
    try_files $uri =404;
}

# HTML files - short cache
location ~* \.html$ {
    root /var/www/app;
    expires 1h;
    add_header Cache-Control "public";
}

# API calls
location /api {
    proxy_pass http://backend-api:8080;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}

# SPA fallback - all other requests go to index.html
location / {
    root /var/www/app;
    try_files $uri $uri/ /index.html;
}
```

### **Pattern 4: File Upload Handling**
```nginx
# Special handling for uploads
location /upload {
    # Large file uploads
    client_max_body_size 100M;
    client_body_temp_path /tmp/nginx_uploads;
    
    # Timeouts for large uploads
    proxy_connect_timeout 300s;
    proxy_send_timeout 300s;
    proxy_read_timeout 300s;
    
    # Don't buffer uploads
    proxy_request_buffering off;
    
    proxy_pass http://upload-service:8080;
}
```

### **Pattern 5: Authentication Proxy**
```nginx
location /admin {
    # Internal only (like K8s internal services)
    internal;
    
    # Check auth cookie
    if ($cookie_session = "") {
        return 401 "Unauthorized";
    }
    
    # Validate with auth service
    auth_request /validate;
    auth_request_set $auth_status $upstream_status;
    
    proxy_pass http://admin-panel:8080;
}

# Auth validation endpoint
location = /validate {
    internal;
    proxy_pass http://auth-service:3000/validate;
    proxy_pass_request_body off;
    proxy_set_header Content-Length "";
}
```

### **Pattern 6: Rate Limiting by Path**
```nginx
# Define rate limit zones
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
limit_req_zone $binary_remote_addr zone=auth_limit:10m rate=5r/s;
limit_req_zone $binary_remote_addr zone=static_limit:10m rate=100r/s;

location /api/auth {
    limit_req zone=auth_limit burst=10 nodelay;
    proxy_pass http://auth-service:3000;
}

location /api {
    limit_req zone=api_limit burst=20;
    proxy_pass http://api-service:8080;
}

location ~* \.(css|js|png)$ {
    limit_req zone=static_limit burst=50;
    root /var/www/static;
}
```

### **Pattern 7: Websocket Proxying**
```nginx
location /ws {
    # Upgrade headers for WebSocket
    proxy_http_version 1.1;
    proxy_set_header Upgrade $http_upgrade;
    proxy_set_header Connection "upgrade";
    
    # Longer timeouts for persistent connections
    proxy_read_timeout 3600s;
    proxy_send_timeout 3600s;
    
    proxy_pass http://websocket-service:8080;
}
```

### **Pattern 8: Health Checks & Monitoring**
```nginx
# Health endpoint (no logging)
location = /health {
    access_log off;
    default_type application/json;
    
    # Check if backend is healthy
    proxy_pass http://backend:8080/health;
    
    # Custom health logic
    # if ($upstream_status != 200) {
    #     return 503;
    # }
    
    return 200 '{"status":"healthy"}';
}

# Metrics endpoint (Prometheus format)
location = /metrics {
    stub_status on;
    access_log off;
    allow 10.0.0.0/8;  # Internal only
    deny all;
}

# Debug endpoint (development only)
location ~ ^/debug/ {
    # Only allow from localhost
    allow 127.0.0.1;
    deny all;
    
    # Enable detailed logging
    rewrite_log on;
    error_log /var/log/nginx/debug.log debug;
    
    echo "Request URI: $request_uri";
    echo "Args: $args";
    echo "Headers: $http_user_agent";
}
```

### **Pattern 9: URL Rewriting Patterns**
```nginx
# 1. Simple prefix removal
location /old {
    rewrite ^/old/(.*)$ /new/$1 permanent;  # 301 redirect
}

# 2. Query string manipulation
location /search {
    # /search?q=term → /api/search?query=term
    rewrite ^/search$ /api/search?query=$arg_q? last;
}

# 3. Path segmentation
location ~ ^/blog/([0-9]{4})/([0-9]{2})/([^/]+)$ {
    # /blog/2023/10/my-post → /posts/2023/10/my-post
    rewrite ^/blog/([0-9]{4})/([0-9]{2})/([^/]+)$ /posts/$1/$2/$3 last;
}

# 4. Trailing slash enforcement
location /page {
    # Remove trailing slash
    rewrite ^/(.*)/$ /$1 permanent;
}

# 5. File extension removal (pretty URLs)
location /products {
    # /products/item.html → serves /products/item
    try_files $uri $uri.html $uri/ =404;
}
```

### **Pattern 10: Security Hardening Patterns**
```nginx
# Block common exploits
location ~* (\.(git|svn|htaccess)|wp-config\.php) {
    deny all;
    return 404;
}

# Protect admin areas
location ~ ^/(admin|wp-admin|dashboard) {
    # IP whitelisting
    allow 10.0.0.0/8;
    allow 192.168.1.0/24;
    deny all;
    
    # Add extra security headers
    add_header X-Frame-Options "DENY";
    add_header X-Content-Type-Options "nosniff";
    add_header Referrer-Policy "no-referrer";
    
    # Rate limiting
    limit_req zone=auth_limit burst=5;
    
    # Basic auth as fallback
    auth_basic "Admin Area";
    auth_basic_user_file /etc/nginx/.htpasswd;
}

# Prevent hotlinking
location ~* \.(jpg|jpeg|png|gif)$ {
    valid_referers none blocked server_names ~\.google\. ~\.bing\. ~\.yahoo\;
    
    if ($invalid_referer) {
        return 403;
        # Or serve a placeholder:
        # rewrite ^ /images/hotlink.jpg;
    }
}

# Hide PHP files (if applicable)
location ~ \.php$ {
    # Only allow index.php
    if ($uri !~ "^/(index|wp-login|wp-admin)\.php") {
        return 404;
    }
    
    fastcgi_pass php:9000;
    # ... rest of PHP config
}
```

---

## 🔧 **ADVANCED LOCATION TECHNIQUES**

### **Nested Locations**
```nginx
location /api {
    # Parent location config
    proxy_set_header X-API-Version v1;
    
    # Nested location
    location /api/admin {
        # Inherits parent config + adds more
        allow 10.0.0.0/8;
        deny all;
        
        proxy_pass http://admin-api:8080;
    }
    
    # Another nested location
    location /api/public {
        proxy_pass http://public-api:8080;
    }
}
```

### **Dynamic Proxy Pass Based on Variables**
```nginx
# Map URI to backend service
map $uri $backend {
    ~^/users   user-service:8080;
    ~^/products product-service:8080;
    ~^/orders  order-service:8080;
    default    default-service:8080;
}

location / {
    proxy_pass http://$backend;
}
```

### **A/B Testing with Split Clients**
```nginx
# Split traffic 50/50
split_clients "${remote_addr}${http_user_agent}" $variant {
    50%     "v2";
    *       "v1";
}

location / {
    if ($variant = "v2") {
        proxy_pass http://app-v2:8080;
    }
    
    proxy_pass http://app-v1:8080;
}
```

### **Conditional Logic in Locations**
```nginx
location / {
    # Method-based routing
    if ($request_method = POST) {
        proxy_pass http://write-api:8080;
    }
    
    if ($request_method = GET) {
        proxy_pass http://read-api:8080;
    }
    
    # Device-based routing
    set $mobile "no";
    if ($http_user_agent ~* "(android|iphone|mobile)") {
        set $mobile "yes";
    }
    
    if ($mobile = "yes") {
        root /var/www/mobile;
    }
    
    root /var/www/desktop;
}
```

---

## ⚠️ **COMMON PITFALLS & SOLUTIONS**

### **1. Trailing Slash Issues**
```nginx
# BAD: Inconsistent behavior
location /api {
    # /api  → backend sees /api
    # /api/ → backend sees /api/
    # /api/users → backend sees /api/users
}

# GOOD: Consistent with trailing slash in proxy_pass
location /api {
    proxy_pass http://backend:8080/;  # Note trailing slash
    # /api  → backend sees /
    # /api/ → backend sees /
    # /api/users → backend sees /users
}

# ALTERNATIVE: Explicit rewrite
location /api {
    rewrite ^/api(/.*)?$ $1 break;
    proxy_pass http://backend:8080;
}
```

### **2. Regex Priority Problems**
```nginx
# BAD: Regex blocks static files
location ~ \.php$ {
    # This will catch /test.php.jpg !
}

# GOOD: More specific regex
location ~ \.php$ {
    # Only if .php is at end of path
    location ~ \.php$ {
        if ($uri ~ \.php\..*$) {
            return 404;
        }
        # ... PHP handling
    }
}

# BETTER: Use exact match for extensions when possible
location ~* ^[^?]+\.php$ {
    # Only matches .php at end before query string
}
```

### **3. Try_files Misuse**
```nginx
# BAD: Infinite loop
location / {
    try_files $uri $uri/ @backend;
}

location @backend {
    proxy_pass http://backend:8080;
    try_files $uri $uri/ @backend;  # OOPS! Recursive
}

# GOOD: Clear fallback chain
location / {
    try_files $uri $uri/ =404;
}

location /api {
    # No try_files for API endpoints
    proxy_pass http://backend:8080;
}
```

---

## 📊 **DEBUGGING LOCATION BLOCKS**

### **Debug Configuration**
```nginx
# Add to location for debugging
location /test {
    # Log matching information
    access_log /var/log/nginx/debug.log debug;
    
    # Echo variables to see what's happening
    add_header X-Debug-Location "test-location";
    add_header X-Debug-Uri $uri;
    add_header X-Debug-Args $args;
    
    # Or use echo module if installed
    # echo "Location matched: test";
    # echo "URI: $uri";
    
    proxy_pass http://backend:8080;
}
```

### **Check Priority Order**
```nginx
# Test config with this pattern
location = /exact {
    add_header X-Match-Type exact;
}

location ^~ /priority {
    add_header X-Match-Type priority-prefix;
}

location ~ regex {
    add_header X-Match-Type regex;
}

location /prefix {
    add_header X-Match-Type prefix;
}
```

---

## 🎯 **QUICK REFERENCE CARD**

### **Location Modifiers:**
- `location = /path` → **Exact match** (highest priority)
- `location ^~ /path` → **Priority prefix** (no regex check)
- `location ~ pattern` → **Case-sensitive regex**
- `location ~* pattern` → **Case-insensitive regex**
- `location /path` → **Regular prefix** (longest wins)

### **Evaluation Order:**
1. `=` (exact)
2. `^~` (priority prefix)  
3. `~` and `~*` (regex, in order)
4. `/path` (prefix, longest first)

### **Pro Tips:**
1. **Always test location order** - use `curl -I` to check headers
2. **Be careful with regex** - they're evaluated for EVERY request
3. **Use `^~` for static files** to skip regex processing
4. **Remember trailing slashes** in `proxy_pass` and `root`
5. **Keep locations simple** - complex logic belongs in backend

This is pure NGINX location block mastery — no Kubernetes concepts, just raw NGINX configuration patterns.