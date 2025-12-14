# Egress NetworkPolicy for Label-Based Cross-Namespace Access

### Requirement

All Pods in namespace **default** with label:

```
level=100x
```

must be able to communicate with Pods that also have:

```
level=100x
```

in the following namespaces:

* `level-1000`
* `level-1001`
* `level-1002`

No other egress traffic should be allowed except DNS.

---

## Initial Issues Encountered

### 1. Invalid Field Usage

Error:

```
unknown field "spec.egress[1].from"
```

Cause:

* `from` is **not valid under egress**
* Correct field for egress rules is `to`

---

### 2. Incorrect policyTypes Value

Error:

```
Unsupported value: "egress"
```

Cause:

* `policyTypes` is case-sensitive
* Must be `Egress`, not `egress`

---

## Corrected NetworkPolicy (Final)

```
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: np-100x
  namespace: default
spec:
  podSelector:
    matchLabels:
      level: 100x
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
          kubernetes.io/metadata.name: level-1000
      podSelector:
        matchLabels:
          level: 100x
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: level-1001
      podSelector:
        matchLabels:
          level: 100x
    - namespaceSelector:
        matchLabels:
          kubernetes.io/metadata.name: level-1002
      podSelector:
        matchLabels:
          level: 100x
```

---

## What This Policy Does

For Pods in **default** namespace with `level=100x`:

* Allows DNS resolution (TCP/UDP 53)
* Allows egress traffic **only** to:

  * Pods with `level=100x`
  * In namespaces:

    * `level-1000`
    * `level-1001`
    * `level-1002`
* Blocks all other outbound traffic by default

---

## Why This Works

* `podSelector` limits policy scope to `level=100x` Pods
* `namespaceSelector` scopes destinations by namespace
* `podSelector` inside `to` further restricts target Pods
* DNS is explicitly allowed to avoid service discovery failures

---

## Verification Commands

All of the following **must succeed**:

```
kubectl exec tester-0 -- curl tester.level-1000.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1001.svc.cluster.local
kubectl exec tester-0 -- curl tester.level-1002.svc.cluster.local
```

---

## Key NetworkPolicy Rules Reinforced

* NetworkPolicies are **deny-by-default** once applied
* Egress rules use `to`, never `from`
* `policyTypes` values are case-sensitive
* DNS must be explicitly allowed
* Cross-namespace traffic requires correct selectors on both namespace and pod labels

---

