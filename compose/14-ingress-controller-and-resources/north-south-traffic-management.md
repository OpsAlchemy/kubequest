# Kubernetes NGINX Ingress

## Core Mental Model: The Universal Pattern

**Ingress routing never invents new behavior — it only combines matching rules with actions.**

```
MATCH  +  ACTION
```

* **MATCH** determines *when* a rule applies (host, path, pathType)
* **ACTION** determines *what happens* after match (forward, rewrite, redirect)

**CRITICAL INSIGHT:** Every Ingress configuration, no matter how complex, is just a combination of these fundamental building blocks. Once you understand the patterns, you can read and write any Ingress configuration.

---

## Part 1: Fundamental Building Blocks Explained

### MATCHING TYPES (The "When" - Decides if rule applies)

| Type       | Description                                      | Use Case                              | Technical Details                              |
| ---------- | ------------------------------------------------ | ------------------------------------- | ---------------------------------------------- |
| **Exact**  | Matches only the exact path string               | Login endpoints, specific API routes  | Most specific match, highest priority          |
| **Prefix** | Matches path and everything under it             | API gateways, static file directories | Most commonly used, good for hierarchies       |
| **Regex**  | Pattern-based matching using regular expressions | Versioned APIs, complex URL patterns  | Most flexible but requires special annotations |

**Important:** Matching never changes the request. It only decides if the rule should be applied.

### ACTION TYPES (The "What" - Decides what happens next)

| Type         | Description                     | Client URL Changes? | HTTP Status | Use Case                   |
| ------------ | ------------------------------- | ------------------- | ----------- | -------------------------- |
| **Forward**  | Send to backend service         | No                  | 200+        | Normal routing             |
| **Rewrite**  | Change path before backend      | No                  | 200+        | API gateways, path mapping |
| **Redirect** | Tell client to make new request | Yes                 | 301/302     | URL migration, maintenance |

---

## Part 2: Complete Examples by Pattern with Detailed Explanations

### Pattern 1: Simple Forwarding (Direct Routing)

#### 1.1 Exact Match → Forward
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: exact-match
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /login
        pathType: Exact
        backend:
          service:
            name: auth-service
            port:
              number: 80
```
**What happens:**
1. Request comes to `example.com/login`
2. Ingress controller checks for Exact match on `/login`
3. Route matched → forwards to `auth-service:80`
4. Backend receives `/login` unchanged

**When to use:** When you need precise endpoint matching, like login, logout, or specific API endpoints that shouldn't match subpaths.

**Key behavior:**
- ✅ Matches: `example.com/login`
- ❌ Does NOT match: `example.com/login/`, `example.com/login/admin`
- Priority: Highest (Exact beats Prefix for same path)

#### 1.2 Prefix Match → Forward
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prefix-match
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 80
```
**What happens:**
1. Request comes to `example.com/api/users`
2. Ingress checks Prefix match on `/api`
3. Request starts with `/api` → match found
4. Forwards to `api-service:80` with full path

**When to use:** For API gateways, microservices routing, or any hierarchical URL structure where you want all subpaths handled by the same service.

**Key behavior:**
- ✅ Matches: `example.com/api`, `example.com/api/users`, `example.com/api/v1/orders`
- ❌ Does NOT match: `example.com/ap`, `example.com/myapi`
- Backend receives path unchanged

#### 1.3 Host + Path Match → Forward
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-path-match
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80
```
**What happens:**
1. DNS resolves `api.example.com` to Ingress IP
2. Host header must exactly match `api.example.com`
3. Path must start with `/v1`
4. Both conditions met → route to `api-v1`

**When to use:** Multi-tenant applications, API versioning by subdomain, or separating services by domain.

**Key behavior:**
- ✅ Matches: `api.example.com/v1`, `api.example.com/v1/users`
- ❌ Does NOT match: `example.com/v1` (wrong host), `api.example.com/v2` (wrong path)
- Host matching is case-insensitive but exact string match

---

### Pattern 2: Rewriting Paths (Path Transformation)

#### 2.1 Prefix + Rewrite (Most Common Pattern)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prefix-rewrite
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: backend-api
            port:
              number: 80
```
**What happens:**
1. Request to `example.com/api/users`
2. Path matches pattern `/api(/|$)(.*)`
3. `$2` captures `users` (the `.*` after `/api`)
4. Rewrite target `/users` sent to backend
5. Client still sees `/api/users` in browser

**Regex breakdown:**
- `/api` - literal match
- `(/|$)` - either slash or end of string
- `(.*)` - capture everything after to `$2`

**When to use:** API gateways, legacy path migration, or when backend expects different URL structure than public API.

**Key behavior:**
- Client URL stays `/api/users`
- Backend receives `/users`
- Perfect for hiding internal structure

#### 2.2 Complex Rewrite with Capture Groups
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: complex-rewrite
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /v2/$1
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /legacy/(.*)
        pathType: Prefix
        backend:
          service:
            name: modern-api
            port:
              number: 80
```
**What happens:**
1. Request to `example.com/legacy/users/123`
2. `(.*)` captures `users/123` as `$1`
3. Rewrite target `/v2/$1` becomes `/v2/users/123`
4. Backend receives new path

**Capture group notes:**
- `$1` = first capture group `(.*)`
- `$2` = second capture group
- Can have up to 9 capture groups (`$1` through `$9`)

**When to use:** Version upgrades, migrating from legacy to new API structure, or path normalization.

#### 2.3 Host-specific Rewrite
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-specific-rewrite
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: api.company.com
    http:
      paths:
      - path: /company-api(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: internal-api
            port:
              number: 80
```
**What happens:**
1. Only applies to `api.company.com`
2. Strips `/company-api` prefix
3. Forwards clean path to backend
4. Different hosts can have different rewrite rules

**When to use:** White-label APIs, partner integrations, or multi-brand deployments.

---

### Pattern 3: Redirects (Client-side URL Changes)

#### 3.1 Permanent Redirect (301)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: permanent-redirect
  annotations:
    nginx.ingress.kubernetes.io/permanent-redirect: https://new.example.com
spec:
  rules:
  - host: old.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: placeholder
            port:
              number: 80
```
**What happens:**
1. Request to `http://old.example.com/any-path`
2. Ingress returns HTTP 301 status
3. `Location: https://new.example.com` header
4. Browser automatically makes new request

**301 vs 302:**
- **301 Permanent**: Browser caches, SEO passes ranking
- **302 Temporary**: Browser doesn't cache, SEO doesn't pass ranking

**When to use:** Domain migration, HTTPS enforcement, permanent URL changes.

#### 3.2 Temporary Redirect (302)
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: temporary-redirect
  annotations:
    nginx.ingress.kubernetes.io/temporary-redirect: /maintenance
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: placeholder
            port:
              number: 80
```
**What happens:**
1. Request to `example.com/app/dashboard`
2. Returns HTTP 302 with `Location: /maintenance`
3. Browser requests `example.com/maintenance`
4. Useful for temporary maintenance pages

**When to use:** Maintenance mode, A/B testing, temporary promotions.

#### 3.3 Path-specific Redirect
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-redirect
  annotations:
    nginx.ingress.kubernetes.io/permanent-redirect: /new-path
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /old-path
        pathType: Exact
        backend:
          service:
            name: placeholder
            port:
              number: 80
```
**What happens:**
1. Only `/old-path` triggers redirect
2. Other paths continue normally
3. Precise control over what gets redirected

**When to use:** Individual page migrations, deprecated endpoints.

---

### Pattern 4: Regex Patterns (Advanced Matching)

#### 4.1 Simple Regex Match
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: simple-regex
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: ^/users/[0-9]+$
        pathType: ImplementationSpecific
        backend:
          service:
            name: user-service
            port:
              number: 80
```
**What happens:**
1. Regex `^/users/[0-9]+$` matches:
   - Starts with `/users/`
   - Followed by one or more digits (`[0-9]+`)
   - End of string (`$`)
2. Only numeric user IDs match

**Regex syntax:**
- `^` = start of string
- `[0-9]` = digit character
- `+` = one or more
- `$` = end of string

**When to use:** Validating URL patterns, restricting to certain formats.

**Key behavior:**
- ✅ Matches: `/users/123`, `/users/456`
- ❌ Does NOT match: `/users/abc`, `/users/123/profile`

#### 4.2 Versioned API Regex
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: versioned-api
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: ^/v[0-9]+/products$
        pathType: ImplementationSpecific
        backend:
          service:
            name: product-api
            port:
              number: 80
```
**What happens:**
1. Matches `/v` + digit + `/products`
2. `[0-9]+` = one or more digits
3. Flexible version handling

**Regex pattern:**
- `^/v` = starts with `/v`
- `[0-9]+` = version number
- `/products$` = ends with `/products`

**When to use:** API versioning, future-proof version matching.

#### 4.3 Regex with Rewrite
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: regex-rewrite
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /api/$1
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: ^/v[0-9]+/(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: unified-api
            port:
              number: 80
```
**What happens:**
1. Request `example.com/v2/users/profile`
2. Regex captures `users/profile` as `$1`
3. Rewrites to `/api/users/profile`
4. All versions map to same backend path

**When to use:** Version abstraction, unified backend API.

---

### Pattern 5: Priority and Specificity (Order Matters)

#### 5.1 Exact vs Prefix Priority
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: priority-example
spec:
  rules:
  - host: example.com
    http:
      paths:
      # Highest priority: Exact match
      - path: /api
        pathType: Exact
        backend:
          service:
            name: api-gateway
            port:
              number: 80
      # Lower priority: Prefix match
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-v2
            port:
              number: 80
      # Even lower: Shorter prefix
      - path: /ap
        pathType: Prefix
        backend:
          service:
            name: legacy-api
            port:
              number: 80
```
**Priority Order:**
1. `Exact` match - highest priority
2. `Longer Prefix` - more specific path wins
3. `Shorter Prefix` - less specific path

**What happens:**
- `example.com/api` → `api-gateway` (Exact wins)
- `example.com/api/users` → `api-v2` (Prefix match)
- `example.com/app` → `legacy-api` (Different prefix)

**When to use:** Override specific endpoints while keeping general routing.

#### 5.2 Multiple Specific Paths
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-path
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api/users
        pathType: Exact
        backend:
          service:
            name: user-service
            port:
              number: 80
      - path: /api/orders
        pathType: Exact
        backend:
          service:
            name: order-service
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: api-gateway
            port:
              number: 80
```
**What happens:**
1. Specific endpoints handled by specialized services
2. General `/api/*` handled by gateway
3. Clear separation of concerns

**When to use:** Microservices architecture, specialized endpoints.

---

### Pattern 6: Advanced Configurations

#### 6.1 Multiple Paths → Single Backend
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: multi-to-one
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: frontend-app
            port:
              number: 80
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: frontend-app
            port:
              number: 80
      - path: /portal
        pathType: Prefix
        backend:
          service:
            name: frontend-app
            port:
              number: 80
```
**What happens:**
- Three different entry points
- All route to same backend service
- Useful for marketing multiple URLs

**When to use:** Brand aliases, legacy URL support, vanity URLs.

#### 6.2 Catch-All Fallback Route
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: catch-all
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: default-app
            port:
              number: 80
```
**What happens:**
1. Matches EVERY path on the host
2. Lowest priority (placed after specific routes)
3. Serves as default/404 handler

**Placement:** Should be LAST in the paths list or in separate Ingress.

**When to use:** Default UI, custom 404 pages, maintenance mode.

#### 6.3 SSL/TLS Redirect + Routing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-redirect
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
    nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
spec:
  tls:
  - hosts:
    - example.com
    secretName: example-tls
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
```
**What happens:**
1. HTTP request on port 80
2. 301 redirect to HTTPS (port 443)
3. TLS termination at Ingress
4. Decrypted traffic forwarded to backend

**Annotations:**
- `ssl-redirect`: Redirect HTTP to HTTPS
- `force-ssl-redirect`: Always redirect, even without TLS config

**When to use:** Production websites, security compliance.

#### 6.4 Path-based TLS
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-tls
spec:
  tls:
  - hosts:
    - secure.example.com
    secretName: secure-tls
  rules:
  - host: secure.example.com
    http:
      paths:
      - path: /admin
        pathType: Prefix
        backend:
          service:
            name: admin-panel
            port:
              number: 443
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: public-site
            port:
              number: 80
```
**What happens:**
- `secure.example.com/admin` → HTTPS only
- `example.com` → HTTP allowed
- Different security levels per path

**When to use:** Mixed security requirements, admin vs public areas.

---

### Pattern 7: Real-World Production Examples

#### 7.1 API Gateway Pattern
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-gateway
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    nginx.ingress.kubernetes.io/configuration-snippet: |
      more_set_headers "X-API-Version: v1";
spec:
  rules:
  - host: api.company.com
    http:
      paths:
      - path: /auth(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: auth-service
            port:
              number: 8080
      - path: /users(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: user-service
            port:
              number: 8080
      - path: /orders(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: order-service
            port:
              number: 8080
```
**What happens:**
1. Single entry point for all services
2. Path-based service routing
3. Headers injected for versioning
4. Clean separation of concerns

**Gateway benefits:**
- Single SSL certificate
- Centralized logging
- Consistent API structure
- Easy service discovery

#### 7.2 Microservices Routing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: microservices
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$2
spec:
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /product-service(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: product-service
            port:
              number: 3000
      - path: /cart-service(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: cart-service
            port:
              number: 3001
      - path: /payment-service(/|$)(.*)
        pathType: Prefix
        backend:
          service:
            name: payment-service
            port:
              number: 3002
```
**What happens:**
- Each service has dedicated path prefix
- Rewrite removes service name prefix
- Services remain independent

**Microservices benefits:**
- Independent scaling
- Separate deployments
- Technology diversity
- Team autonomy

#### 7.3 A/B Testing Routing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ab-testing
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "30"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-v2
            port:
              number: 80
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: main-app
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app-v1
            port:
              number: 80
```
**What happens:**
- 30% traffic to `app-v2`
- 70% traffic to `app-v1`
- Weight-based load balancing

**Canary annotations:**
- `canary: "true"` - marks as canary ingress
- `canary-weight: "30"` - percentage to canary
- `canary-by-header` - header-based routing

**When to use:** Gradual rollouts, feature flags, experimentation.

#### 7.4 Geographic Routing
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: geo-routing
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      if ($http_cf_ipcountry = "US") {
        set $upstream "us-service";
      }
      if ($http_cf_ipcountry = "EU") {
        set $upstream "eu-service";
      }
spec:
  rules:
  - host: global.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: default-service
            port:
              number: 80
```
**What happens:**
- Cloudflare header `CF-IPCountry` checked
- US traffic → US service
- EU traffic → EU service
- Fallback to default

**Geo-routing benefits:**
- Reduced latency
- Data sovereignty compliance
- Regional features

---

### Pattern 8: Complex Regex Patterns

#### 8.1 UUID Pattern Matching
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: uuid-pattern
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: ^/users/[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$
        pathType: ImplementationSpecific
        backend:
          service:
            name: user-detail-service
            port:
              number: 8080
```
**Regex breakdown:**
- `[0-9a-f]` - hex character
- `{8}` - exactly 8 characters
- Standard UUID format
- Validates URL structure

**When to use:** Resource endpoints with UUID identifiers.

#### 8.2 File Extension Matching
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: file-extensions
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
spec:
  rules:
  - host: static.example.com
    http:
      paths:
      - path: ^.*\.(jpg|jpeg|png|gif|ico)$
        pathType: ImplementationSpecific
        backend:
          service:
            name: image-service
            port:
              number: 80
      - path: ^.*\.(js|css)$
        pathType: ImplementationSpecific
        backend:
          service:
            name: asset-service
            port:
              number: 80
```
**What happens:**
- Images → image optimization service
- JS/CSS → asset pipeline service
- Content-type based routing

**Regex pattern:**
- `.*` - any characters
- `\.` - literal dot
- `(jpg|jpeg|png|gif|ico)` - extension list

#### 8.3 Complex Path Restructuring
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: path-restructure
  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /api/v2/$2/$1
spec:
  rules:
  - host: migrate.example.com
    http:
      paths:
      - path: ^/old/v1/([^/]+)/([^/]+)/?
        pathType: ImplementationSpecific
        backend:
          service:
            name: new-api
            port:
              number: 8080
```
**What happens:**
- `^/old/v1/([^/]+)/([^/]+)/?`
- `$1` = first segment after `/old/v1/`
- `$2` = second segment
- Reorders to `/api/v2/$2/$1`

**Example transformation:**
- `/old/v1/users/profile` → `/api/v2/profile/users`
- Complete URL restructuring

---

### Pattern 9: Rate Limiting and Security

#### 9.1 Path-based Rate Limiting
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rate-limited
  annotations:
    nginx.ingress.kubernetes.io/limit-rps: "10"
    nginx.ingress.kubernetes.io/limit-rpm: "100"
    nginx.ingress.kubernetes.io/limit-whitelist: "10.0.0.0/8"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /public
        pathType: Prefix
        backend:
          service:
            name: public-api
            port:
              number: 8080
      - path: /internal
        pathType: Prefix
        backend:
          service:
            name: internal-api
            port:
              number: 8080
```
**Rate limiting settings:**
- `limit-rps`: 10 requests per second
- `limit-rpm`: 100 requests per minute
- `limit-whitelist`: IPs exempt from limits

**When to use:** API protection, DDoS mitigation, fair usage policies.

#### 9.2 Authentication Required Paths
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: auth-paths
  annotations:
    nginx.ingress.kubernetes.io/auth-type: basic
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    nginx.ingress.kubernetes.io/auth-realm: "Authentication Required"
spec:
  rules:
  - host: admin.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: admin-panel
            port:
              number: 80
```
**What happens:**
1. Request to admin area
2. 401 Unauthorized returned
3. Browser shows auth dialog
4. Valid credentials → access granted

**Auth types supported:**
- Basic auth (shown)
- External auth (OAuth, JWT)
- Client certificate

---

### Pattern 10: Header-based Routing

#### 10.1 Mobile vs Desktop
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: device-routing
  annotations:
    nginx.ingress.kubernetes.io/server-snippet: |
      set $mobile_rewrite "no";
      if ($http_user_agent ~* "(android|iphone|mobile)") {
        set $mobile_rewrite "yes";
      }
      if ($mobile_rewrite = "yes") {
        rewrite ^/(.*)$ /mobile/$1 break;
      }
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web-app
            port:
              number: 80
```
**What happens:**
- Checks `User-Agent` header
- Mobile devices → `/mobile/` prefix
- Desktop → normal routing
- Device-specific experiences

**When to use:** Responsive web apps, mobile optimization.

#### 10.2 API Version Header
```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: header-versioning
  annotations:
    nginx.ingress.kubernetes.io/configuration-snippet: |
      if ($http_x_api_version = "v2") {
        rewrite ^/(.*)$ /v2/$1 break;
      }
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: api-service
            port:
              number: 8080
```
**What happens:**
- Header `X-API-Version: v2` triggers rewrite
- Path prefix added based on header
- Clean version negotiation

**Header-based benefits:**
- URL remains clean
- Client controls version
- Easy to test different versions

---

## Part 3: Golden Rules & Best Practices Explained

### 1. Matching Priority Rules
**Order of precedence:**
1. **Exact path match** - Most specific
2. **Longer prefix path** - More specific prefix
3. **Shorter prefix path** - Less specific prefix
4. **Catch-all** - Least specific

**Example of priority:**
```yaml
# Order matters within same Ingress
# 1. Exact /api → highest priority
# 2. Prefix /api/v2 → medium priority  
# 3. Prefix /api → lower priority
# 4. Prefix / → lowest priority
```

### 2. Rewrite Pattern Guidelines
**Capture group numbering:**
- `$1` = first parentheses group
- `$2` = second parentheses group
- Max 9 groups (`$1` through `$9`)

**Common patterns:**
```yaml
# Strip prefix
path: /api(/|$)(.*)
rewrite-target: /$2

# Add prefix  
path: /(.*)
rewrite-target: /api/$1

# Complex transformation
path: /old/([^/]+)/([^/]+)
rewrite-target: /new/$2/$1
```

### 3. Redirect Best Practices
**Status code selection:**
- **301 Permanent**: Domain moves, permanent changes
- **302 Temporary**: Maintenance, A/B testing
- **307/308**: Preserve HTTP method (rarely used in Ingress)

**Common mistakes:**
```yaml
# WRONG: Redirect loop
permanent-redirect: /  # redirects to itself

# CORRECT: External URL or different path
permanent-redirect: https://new.example.com
```

### 4. Regex-Specific Requirements
**Mandatory for regex:**
```yaml
annotations:
  nginx.ingress.kubernetes.io/use-regex: "true"
  
paths:
- path: ^/pattern$
  pathType: ImplementationSpecific  # MUST be this
```

**Regex testing tips:**
1. Test patterns locally first
2. Use regex testers
3. Start simple, add complexity
4. Consider performance impact

### 5. Testing Checklist Explained
**Step-by-step validation:**

1. **Host matching:**
   ```bash
   curl -H "Host: example.com" http://ingress-ip/
   ```

2. **Path matching:**
   ```bash
   # Test exact
   curl http://ingress-ip/login
   
   # Test prefix
   curl http://ingress-ip/api/users
   ```

3. **Rewrite verification:**
   ```bash
   # Check backend logs
   kubectl logs deployment/backend
   
   # Or proxy through to see
   kubectl port-forward service/backend 8080:80
   ```

4. **Redirect testing:**
   ```bash
   curl -v http://ingress-ip/old-path
   # Should see 301/302 and Location header
   ```

5. **Priority testing:**
   ```bash
   # Test overlapping paths
   curl http://ingress-ip/api  # Should use exact if exists
   curl http://ingress-ip/api/v2  # Should use prefix
   ```

---

## Part 4: Troubleshooting Common Issues (Detailed)

### 1. Rule Not Matching
**Symptoms:**
- 404 errors
- Wrong backend service
- Default backend used

**Debug steps:**
```bash
# 1. Check Ingress configuration
kubectl describe ingress <name>

# 2. Check Ingress controller logs
kubectl logs -n ingress-nginx <controller-pod>

# 3. Verify host header
curl -v -H "Host: correct-host.com" http://ingress-ip/

# 4. Check pathType matches expectation
# Exact vs Prefix confusion is common
```

**Common causes:**
- Wrong hostname in request
- PathType mismatch
- Trailing slash differences
- Higher priority rule intercepting

### 2. Rewrite Not Working
**Symptoms:**
- Backend receives wrong path
- 404 from backend
- Path transformation not happening

**Debug steps:**
```bash
# 1. Check rewrite annotation syntax
# Common error: wrong capture group number

# 2. Verify path pattern matches
# Test pattern: does it capture what you expect?

# 3. Check backend expectations
# Does backend expect rewritten path?

# 4. Look at nginx config
kubectl exec -n ingress-nginx <pod> -- cat /etc/nginx/nginx.conf | grep rewrite
```

**Common mistakes:**
- Capture groups don't match path pattern
- Using `$1` when should use `$2`
- Missing regex `use-regex: "true"` annotation
- PathType not `ImplementationSpecific` for regex

### 3. Redirect Loop
**Symptoms:**
- Infinite redirects
- Browser shows "too many redirects"
- Network tab shows chain of 301/302

**Debug steps:**
```bash
# 1. Check redirect target
# Is it redirecting to itself?

# 2. Check SSL redirect configuration
# Multiple SSL redirects can cause loops

# 3. Look for conflicting rules
kubectl get ingress --all-namespaces

# 4. Test with curl to see redirect chain
curl -L -v http://ingress-ip/problem-path
```

**Common causes:**
- Redirect target matches source path
- Multiple Ingresses with same host/path
- SSL redirect + path redirect conflict
- External redirect without protocol (http://)

### 4. Priority Problems
**Symptoms:**
- Wrong service handles request
- Specific endpoint not working
- Unexpected routing behavior

**Debug steps:**
```bash
# 1. List all Ingress rules sorted by priority
# Exact > Longer Prefix > Shorter Prefix

# 2. Check all Ingresses for the host
kubectl get ingress -o yaml | grep -A5 -B5 "example.com"

# 3. Test specific paths
curl http://ingress-ip/specific
curl http://ingress-ip/specific/child

# 4. Check nginx.conf for rule order
kubectl exec -n ingress-nginx <pod> -- grep -n "example.com" /etc/nginx/nginx.conf
```

**Priority rules to remember:**
1. Exact path beats prefix path
2. Longer prefix beats shorter prefix
3. Within same Ingress, order in YAML matters
4. Across Ingresses, controller merges by specificity

### 5. TLS/SSL Issues
**Symptoms:**
- Certificate warnings
- No HTTPS redirect
- Mixed content errors

**Debug steps:**
```bash
# 1. Check TLS secret exists
kubectl get secret <tls-secret-name>

# 2. Verify secret contains cert and key
kubectl describe secret <tls-secret-name>

# 3. Check SSL redirect annotation
# Should be: ssl-redirect: "true"

# 4. Test HTTP and HTTPS separately
curl http://example.com
curl https://example.com -k  # -k ignores cert errors for testing
```

**Common issues:**
- Secret not in same namespace as Ingress
- Wrong secret name in TLS spec
- Certificate expired or not valid for domain
- Missing SSL redirect annotation

---

## Part 5: Performance Optimization Tips

### 1. Path Matching Optimization
**Order paths by frequency:**
```yaml
# Put most frequently accessed paths first
paths:
- path: /api/v1/users  # Most common
- path: /api/v1/orders # Less common  
- path: /api/v1/admin  # Rare
```

**Use appropriate pathType:**
- **Exact**: When you know exact path
- **Prefix**: For hierarchical structures
- **Regex**: Only when necessary (has performance cost)

### 2. Rewrite Performance
**Simple rewrites are faster:**
```yaml
# FAST: Simple prefix strip
rewrite-target: /$2

# SLOWER: Complex regex with multiple groups
rewrite-target: /api/$3/$1/$2
```

**Cache considerations:**
- Rewrites may affect cache keys
- Consider adding cache-control headers
- Test cache behavior after rewrites

### 3. Scale Considerations
**Multiple small Ingresses vs one large:**
- **Small Ingresses**: Easier to manage, independent updates
- **Large Ingress**: Single point of control, but complex

**Recommendation:**
- Group by domain or team
- Keep related paths together
- Use labels for organization

---

## Part 6: Migration and Versioning Strategies

### 1. API Version Migration
**Blue-green deployment:**
```yaml
# v1 Ingress (current)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-v1
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v1
        pathType: Prefix
        backend:
          service:
            name: api-v1
            port:
              number: 80

# v2 Ingress (new)
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: api-v2
  annotations:
    nginx.ingress.kubernetes.io/canary: "true"
    nginx.ingress.kubernetes.io/canary-weight: "10"
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /v2
        pathType: Prefix
        backend:
          service:
            name: api-v2
            port:
              number: 80
```

### 2. Path Migration Pattern
**Gradual migration with redirects:**
```yaml
# Phase 1: Both paths active
paths:
- path: /old-path
  pathType: Prefix
  backend:
    service:
      name: new-service  # Same as new-path
- path: /new-path
  pathType: Prefix
  backend:
    service:
      name: new-service

# Phase 2: Redirect old to new
paths:
- path: /old-path
  pathType: Prefix
  backend:
    service:
      name: placeholder
annotations:
  nginx.ingress.kubernetes.io/permanent-redirect: /new-path
```

---

## Final Summary: Mental Model Diagram

```
                    ┌─────────────────────────────────────────┐
                    │           Ingress Controller            │
                    └─────────────────────────────────────────┘
                                    │
                    ┌───────────────▼────────────────┐
   Request ────────►│          HOST MATCH?           │
                    │  api.example.com  │  NO       │
                    │       YES         │           │
                    └──────────┬─────────────────────┘
                               │
                    ┌──────────▼────────────────┐
                    │         PATH MATCH?       │
                    │  /api/*  │  /admin  │ NO │
                    │   YES    │    YES   │    │
                    └─────┬─────────┬───────────┘
                          │         │
                ┌─────────▼─┐   ┌───▼─────────┐
                │   ACTION  │   │   ACTION    │
                │  Rewrite  │   │  Redirect   │
                │  to /$2   │   │  to /login  │
                └─────┬─────┘   └─────┬───────┘
                      │               │
                ┌─────▼───────────────▼─────┐
                │       Backend Service     │
                └───────────────────────────┘
```

**Key Takeaways:**

1. **Always MATCH + ACTION**: Every rule has these two parts
2. **Three match types**: Exact, Prefix, Regex
3. **Three action types**: Forward, Rewrite, Redirect  
4. **Priority matters**: Exact > Longer Prefix > Shorter Prefix
5. **Rewrite ≠ Redirect**: Know the difference
6. **Test thoroughly**: Especially priority and edge cases

**Remember:** Complexity comes from combination, not from new concepts. Master the basics, and you can build any routing configuration.