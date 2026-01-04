# Gateway API Practice Questions

## **1. Simple Host-Based Routing**
You need to route traffic based on hostnames to different services:
- `app.example.com` → `frontend-service:8080`
- `api.example.com` → `backend-service:3000`

Both should use the existing Gateway named `main-gateway` on port 80.

**Task:** Write the HTTPRoute YAML(s) to implement this.

## **2. Path Rewriting (API Gateway Pattern)**
You have a single domain `services.company.com` with these requirements:
- `/shop/products` → `product-service:8080` (should receive `/products`)
- `/shop/cart` → `cart-service:9090` (should receive `/cart`)  
- `/auth/login` → `auth-service:7070` (should receive `/login`)

**Task:** Create a single HTTPRoute that rewrites paths to remove the `/shop` and `/auth` prefixes.

## **3. Path Redirects (Migration)**
You're migrating from an old path structure to a new one:
- `/old/dashboard` → redirect to `/new/dashboard` (301 permanent)
- `/old/api/v1` → redirect to `/api/v2` (301 permanent)
- `/temp/redirect` → redirect to `/new/temp` (302 temporary)

**Task:** Write an HTTPRoute that handles these redirects.

## **4. TLS Configuration with Multiple Hostnames**
You have a Gateway `secure-gateway` with an HTTPS listener on port 443. You need to:
1. Configure TLS with a certificate secret named `wildcard-tls`
2. Route traffic for `app.company.com` and `api.company.com` to their respective services
3. Ensure only HTTPS traffic is accepted (no HTTP)

**Task:** Write both the Gateway update and HTTPRoute(s) for TLS configuration.

## **5. Exact vs Prefix Path Matching**
You have these specific routing requirements:
- `/api/health` (exact) → `health-check:8080`
- `/api/users` (prefix) → `user-service:3000` (matches `/api/users`, `/api/users/123`, etc.)
- `/admin` (exact) → `admin-panel:9000`
- `/admin/config` (exact) → `config-service:4000` (higher priority than `/admin` prefix)

**Task:** Create an HTTPRoute with proper path matching types and rule ordering.