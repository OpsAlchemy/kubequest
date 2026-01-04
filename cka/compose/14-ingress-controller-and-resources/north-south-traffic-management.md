# Kubernetes Ingress

---

## Core Mental Model

Ingress does **only two things**, always in this order:

```
MATCH  →  ACTION
```

* **MATCH** decides **whether** a rule applies to a request
* **ACTION** decides **what happens** after the rule matches

Ingress **never**:

* Creates traffic
* Modifies traffic implicitly
* Chooses backends randomly

Everything you see in Ingress YAML is either:

* A **matching constraint**, or
* An **explicit instruction**

If something changes (path, protocol, destination), there is **always a line in YAML causing it**.

---

## 1. MATCHING THEORY (WHEN A RULE APPLIES)

Ingress matching happens in **two layers**:

1. **Host match**
2. **Path match**

If **either fails**, the rule is ignored.

---

### 1.1 Host Matching (HTTP Host Header)

Ingress matches against the HTTP `Host` header.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: host-match
spec:
  rules:
  - host: api.example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: app
            port:
              number: 80
```

**Theory**

* Host matching is **exact**
* Case-insensitive
* No wildcards unless controller-specific (not tested in CKA)

**Implications**

* `api.example.com` ≠ `example.com`
* Requests without the correct Host header skip this rule entirely
* On the exam, missing Host is a **common silent failure**

---

## 2. PATH MATCHING THEORY (CKA CRITICAL)

After host match succeeds, Ingress evaluates **path rules**.

Ingress supports **three pathTypes**, each with **different semantics and priority**.

---

### 2.1 Exact Path Match (Highest Priority)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: exact-path
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

**Theory**

* Exact means **byte-for-byte equality**
* No normalization
* No implicit trailing slash handling

**Matches**

* `/login`

**Does NOT match**

* `/login/`
* `/login/admin`

**Why it exists**

* Guarantees deterministic routing
* Used for security-sensitive or fixed endpoints

**Exam Insight**
Exact paths **always override** Prefix paths with the same value.

---

### 2.2 Prefix Path Match (MOST USED)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: prefix-path
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

**Theory**

* Prefix matches if the request path **starts with** the prefix
* Path is not modified
* This is hierarchical routing

**Matches**

* `/api`
* `/api/users`
* `/api/v1/orders`

**Does NOT match**

* `/ap`
* `/myapi`

**Why it is dominant**

* Natural fit for APIs and microservices
* Minimal ambiguity
* Best performance

**Exam Insight**
If unsure which pathType to use → **Prefix** is almost always correct.

---

### 2.3 ImplementationSpecific (Regex)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: regex-path
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

**Theory**

* Meaning depends on Ingress controller
* NGINX interprets this as a regular expression
* Kubernetes does **not validate** regex correctness

**Matches**

* `/users/123`

**Does NOT match**

* `/users/abc`
* `/users/123/profile`

**Mandatory Requirements**

* `use-regex: "true"`
* `pathType: ImplementationSpecific`

**Exam Insight**
Regex is tested only at a **basic level**:

* Numeric IDs
* Simple anchors (`^`, `$`)
* Single capture groups

---

## 3. ACTION THEORY (WHAT HAPPENS AFTER MATCH)

Once a rule matches, **exactly one action occurs**.

---

## 3.1 Forward (DEFAULT BEHAVIOR)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: forward-only
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: app-service
            port:
              number: 80
```

**Theory**

* Forwarding is implicit
* No annotation required
* Request is proxied as-is

**What does NOT change**

* URL in browser
* Path
* HTTP method

**Exam Insight**
If no annotation is present, the action is **always forward**.

---

## 3.2 Rewrite (SERVER-SIDE PATH TRANSFORMATION)

Rewrite changes the **path sent to the backend**, not what the client sees.

---

### Strip Prefix (MOST IMPORTANT REWRITE)

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-strip
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
            name: backend
            port:
              number: 80
```

**Theory**

* Regex captures parts of the path
* Rewrite replaces the matched path before proxying

**Flow**

* Client → `/api/users`
* Match → `/api(/|$)(.*)`
* `$2 = users`
* Backend receives `/users`

**Why this pattern exists**

* Backends often do not know public URL structure
* API gateway behavior without changing services

---

### Add Prefix Rewrite

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: rewrite-add
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /v1/$1
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /(.*)
        pathType: Prefix
        backend:
          service:
            name: api
            port:
              number: 80
```

**Theory**

* Entire path is captured
* New prefix is injected

**Flow**

* `/users` → backend sees `/v1/users`

---

## 3.3 Redirect (CLIENT-SIDE ACTION)

Redirect tells the **client** to issue a **new request**.

---

### Permanent Redirect (301)

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
            name: dummy
            port:
              number: 80
```

**Theory**

* Client receives `301`
* Browser updates address bar
* Search engines cache this

---

### Temporary Redirect (302)

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
            name: dummy
            port:
              number: 80
```

**Theory**

* Client retries at new location
* No caching assumption

---

## 4. PRIORITY THEORY (EXAM FAVORITE)

Ingress chooses **one rule only**, based on specificity.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: priority
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /api
        pathType: Exact
        backend:
          service:
            name: exact-api
            port:
              number: 80
      - path: /api
        pathType: Prefix
        backend:
          service:
            name: prefix-api
            port:
              number: 80
      - path: /
        pathType: Prefix
        backend:
          service:
            name: default
            port:
              number: 80
```

**Priority Order**

1. Exact
2. Longer Prefix
3. Shorter Prefix
4. `/` catch-all

**Exam Insight**
YAML order does **not** override specificity.

---

## 5. MULTI-PATH THEORY

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
      - path: /web
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
      - path: /app
        pathType: Prefix
        backend:
          service:
            name: frontend
            port:
              number: 80
```

**Theory**

* Multiple public entry points
* Single backend
* No conflict because prefixes differ

---

## 6. CATCH-ALL THEORY

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

**Theory**

* Matches everything
* Used as fallback
* Lowest priority possible

---

## 7. TLS THEORY (CKA LEVEL)

### TLS Termination

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: tls-ingress
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
            name: web
            port:
              number: 80
```

**Theory**

* TLS ends at Ingress
* Backend sees plain HTTP
* Secret must be in same namespace

---

### HTTP → HTTPS Redirect

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: ssl-redirect
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "true"
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: web
            port:
              number: 80
```

**Theory**

* HTTP requests receive redirect
* HTTPS requests are forwarded

---

## 8. CKA FAILURE MODES (WHY THINGS BREAK)

* Host mismatch → rule ignored
* Exact vs Prefix confusion → wrong backend
* Regex without `use-regex` → no match
* Wrong capture group → broken rewrite
* TLS secret missing → HTTPS fails

---

## FINAL CKA MENTAL MODEL (MEMORIZE)

* Ingress = **MATCH → ACTION**
* Match = Host + Path
* PathTypes = Exact | Prefix | ImplementationSpecific
* Priority = Exact > Longer Prefix > Shorter Prefix > /
* Forward is default
* Rewrite changes backend path only
* Redirect changes client behavior
* Regex requires annotation + ImplementationSpecific

This is the **entire CKA Ingress surface area**.
