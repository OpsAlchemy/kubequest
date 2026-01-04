# Creating Ingress via kubectl CLI with Prefix Paths and IngressClass

### Objective

Expose two Deployments (`europe`, `asia`) in namespace `world` via a single Ingress:

* Host: `world.universe.mine`
* Paths:

  * `/europe/` → service `europe:80`
  * `/asia/` → service `asia:80`
* `pathType: Prefix`
* Ingress class: `nginx`

---

## Key CLI Behaviors (Critical)

### 1. Default pathType

```
--rule=host/path=svc:port
```

Creates:

```
pathType: Exact
```

This is **always the default**.

---

### 2. How to force `pathType: Prefix` via CLI

Use `*` or `/*` in the rule:

```
--rule=host/path*=svc:port
--rule=host/path/*=svc:port
```

Result:

```
pathType: Prefix
```

---

### 3. Trailing Slash Behavior

```
/europe*=svc → path: /europe
/europe/*=svc → path: /europe/
```

Both are valid `Prefix` paths.

---

### 4. IngressClass must be explicit

* `--class` sets:

  ```
  spec.ingressClassName
  ```
* Short flag `-c` does **not** exist
* Without class, controller may ignore the Ingress

---

## Final Working Command (Correct)

```
kubectl create ingress world \
  -n world \
  --class=nginx \
  --rule=world.universe.mine/europe/*=europe:80 \
  --rule=world.universe.mine/asia/*=asia:80
```

---

## Resulting Ingress Spec (Verified)

```
spec:
  ingressClassName: nginx
  rules:
  - host: world.universe.mine
    http:
      paths:
      - path: /europe/
        pathType: Prefix
        backend:
          service:
            name: europe
            port:
              number: 80
      - path: /asia/
        pathType: Prefix
        backend:
          service:
            name: asia
            port:
              number: 80
```

---

## Required Services (ClusterIP)

Services must exist **before** Ingress routing works:

```
kubectl -n world expose deploy europe --port 80
kubectl -n world expose deploy asia --port 80
```

---

## Common Mistakes Observed

* Using `-class` instead of `--class`
* Forgetting ingress class entirely
* Expecting Prefix without `*`
* Creating Ingress before Services
* Assuming controller auto-selects Ingress

---

