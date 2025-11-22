k expose deploy asia --port=80 --target-port=80
k expose deploy europe --port=80 --target-port=80

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: world
  namespace: world
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  ingressClassName: nginx
  rules:
  - http:
      paths:
      - path: /europe
        pathType: Prefix
        backend:
          service:
            name: europe
            port:
              number: 80
      - path: /asia
        pathType: Prefix
        backend:
          service:
            name: asia
            port:
              number: 80
    host: world.universe.mine
```



**Exactly what you need to know:**

## 🎯 **What This Ingress Does:**

1. **Routes traffic based on URL path:**
   - `world.universe.mine/europe` → goes to **europe** service
   - `world.universe.mine/asia` → goes to **asia** service

2. **Uses NGINX Ingress Controller** (`ingressClassName: nginx`)

3. **Stripes the path** (`rewrite-target: /`) - so:
   - Request to `world.universe.mine/europe/page` → service receives `/page`
   - Request to `world.universe.mine/asia/about` → service receives `/about`

## ⚡ **What You MUST Have:**

1. **NGINX Ingress Controller installed** in your cluster
2. **Services named `europe` and `asia`** exposed on port 80
3. **DNS entry** pointing `world.universe.mine` to your ingress controller IP

## 🔧 **Quick Check Commands:**

```bash
# Check if ingress controller exists
kubectl get pods -n ingress-nginx

# Check services
kubectl get svc europe asia

# Test the ingress
curl http://world.universe.mine/europe
curl http://world.universe.mine/asia
```

That's it! The ingress acts as a **path-based router** for your two services.