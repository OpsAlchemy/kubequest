# NGINX Ingress Controller Practice Questions

## **1. Simple Host-Based Routing with NGINX Ingress**
You need to route traffic based on hostnames to different services using NGINX Ingress Controller:
- `app.example.com` → `frontend-service:8080` 
- `api.example.com` → `backend-service:3000`
- Both should be served on port 80
- Use the NGINX Ingress Controller (already installed)

## **2. Path Rewriting with NGINX Annotations**
You have a single domain `services.company.com` with these requirements using NGINX Ingress:
- `/shop/products` → `product-service:8080` (should receive `/products`)
- `/shop/cart` → `cart-service:9090` (should receive `/cart`)  
- `/auth/login` → `auth-service:7070` (should receive `/login`)
- You must use NGINX Ingress annotations for path rewriting

## **3. Path Redirects with NGINX Configuration**
You're migrating from an old path structure to a new one using NGINX Ingress:
- `/old/dashboard` → redirect to `/new/dashboard` (301 permanent)
- `/old/api/v1` → redirect to `/api/v2` (301 permanent)  
- `/temp/redirect` → redirect to `/new/temp` (302 temporary)
- Domain: `redirect.example.com`
- Use NGINX Ingress annotations for redirects

## **4. TLS Configuration with NGINX Ingress**
You need to configure TLS for NGINX Ingress with:
1. TLS certificate stored in secret named `wildcard-tls`
2. Serve `app.company.com` and `api.company.com` over HTTPS
3. Redirect HTTP to HTTPS automatically
4. Use appropriate NGINX Ingress annotations

## **5. Exact vs Prefix Path Matching with NGINX**
You have these specific routing requirements using NGINX Ingress:
- `/api/health` (exact match only) → `health-check:8080`
- `/api/users` (prefix match) → `user-service:3000` (matches `/api/users`, `/api/users/123`, etc.)
- `/admin` (exact match) → `admin-panel:9000`
- `/admin/config` (exact match, higher priority than `/admin` prefix) → `config-service:4000`
- Implement proper path matching using NGINX Ingress path types and annotations if needed