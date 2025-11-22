**Note on Ingress Annotations and ingressClassName:**

## rewrite-target Purpose:
- Strips path prefixes before forwarding to backend services
- Without it: /europe/page -> service receives /europe/page (usually breaks apps)
- With it: /europe/page -> service receives /page (works with standard apps)

## Other Common NGINX Ingress Annotations:

### Path Rewriting:
```yaml
# Alternative to rewrite-target (more specific)
nginx.ingress.kubernetes.io/rewrite-path: /
```

### SSL/HTTPS:
```yaml
# Force HTTPS redirect
nginx.ingress.kubernetes.io/force-ssl-redirect: "true"

# Custom SSL certificate  
nginx.ingress.kubernetes.io/ssl-certificate: "namespace/secret-name"
```

### Authentication:
```yaml
# Basic auth
nginx.ingress.kubernetes.io/auth-type: basic
nginx.ingress.kubernetes.io/auth-secret: basic-auth

# CORS
nginx.ingress.kubernetes.io/enable-cors: "true"
```

### Rate Limiting:
```yaml
nginx.ingress.kubernetes.io/limit-rps: "100"
nginx.ingress.kubernetes.io/limit-connections: "10"
```

## CRITICAL: Annotation and ingressClassName Relationship

### Annotations are 1:1 with ingressClassName!

**WRONG:** Mixing annotations from different controllers
```yaml
ingressClassName: nginx  # NGINX controller
annotations:
  kubernetes.io/ingress.class: "nginx"  # OK
  nginx.ingress.kubernetes.io/rewrite-target: /  # OK (NGINX-specific)
  alb.ingress.kubernetes.io/scheme: internet-facing  # WRONG (AWS ALB annotation)
```

**CORRECT:** Consistent controller-specific annotations
```yaml
# For NGINX Ingress Controller
ingressClassName: nginx
annotations:
  nginx.ingress.kubernetes.io/rewrite-target: /
  nginx.ingress.kubernetes.io/ssl-redirect: "true"

# For AWS ALB Controller
ingressClassName: alb  
annotations:
  alb.ingress.kubernetes.io/scheme: internet-facing
  alb.ingress.kubernetes.io/target-type: ip
```

## Key Takeaway:
- Annotations are controller-specific
- Must match your ingressClassName
- Mixing different controller annotations will break your ingress
- Check your ingress controller's documentation for supported annotations

**Always use annotations that match your ingressClassName!**