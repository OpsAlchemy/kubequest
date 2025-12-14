# Restricting Cross-Namespace Traffic Using NetworkPolicies

### Scenario Summary

There are two namespaces:

* `space1`
* `space2`

Workloads exist in both namespaces.
The requirement is to **restrict traffic using NetworkPolicies** such that:

* Pods in `space1`:

  * Can resolve DNS
  * Can access Pods in `space2`
  * Cannot access arbitrary external destinations
* Pods in `space2`:

  * Only accept traffic originating from `space1`

---

## NetworkPolicy in `space1` (Egress Control)

### Policy Applied

```
kind: NetworkPolicy
metadata:
  name: np
  namespace: space1
spec:
  podSelector: {}
  policyTypes:
  - Egress
  egress:
  - ports:
    - port: 53
      protocol: TCP
    - port: 53
      protocol: UDP
  - to:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: space2
```

### Effect

For **all Pods in space1**:

* ✅ DNS resolution allowed (UDP/TCP 53)
* ✅ Traffic allowed to Pods in namespace `space2`
* ❌ All other outbound traffic blocked by default

---

## NetworkPolicy in `space2` (Ingress Control)

### Policy Applied

```
kind: NetworkPolicy
metadata:
  name: np
  namespace: space2
spec:
  podSelector: {}
  policyTypes:
  - Ingress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: space1
```

### Effect

For **all Pods in space2**:

* ✅ Incoming traffic allowed **only from space1**
* ❌ Traffic from default, kube-system, or external sources denied

---

## Observed Behavior (Validation)

### From `space1` Pod

* DNS resolution works:

  ```
  nslookup google.com
  ```
* Direct Pod IP access works:

  ```
  curl http://192.168.x.x
  ```
* Service DNS access across namespaces works:

  ```
  curl microservice1.space2.svc.cluster.local
  ```

---

### From `default` Namespace

* Access to `space2` services fails:

  ```
  curl microservice1.space2.svc.cluster.local
  → timeout
  ```

---

### From `kube-system`

* Access blocked unless explicitly allowed
* Confirms ingress restriction is enforced

---

## Important NetworkPolicy Rules Illustrated

### 1. NetworkPolicies Are Namespace-Scoped

* Policies only affect Pods **within their namespace**
* Cross-namespace control requires:

  * Egress in source namespace
  * Ingress in destination namespace

---

### 2. `podSelector: {}` Means “All Pods”

Applies policy to **every Pod** in the namespace.

---

### 3. DNS Must Be Explicitly Allowed

If DNS (port 53) is not allowed:

* Service discovery breaks
* `curl service.namespace.svc.cluster.local` fails

---

### 4. NetworkPolicy Is Deny-By-Default Once Applied

Once a policy exists:

* Only traffic explicitly allowed is permitted
* Everything else is dropped silently

---

## Final Result

| Source Namespace | Destination Namespace | Result  |
| ---------------- | --------------------- | ------- |
| space1           | space2                | Allowed |
| space1           | Internet              | Blocked |
| default          | space2                | Blocked |
| kube-system      | space2                | Blocked |
| space1           | DNS                   | Allowed |

---

