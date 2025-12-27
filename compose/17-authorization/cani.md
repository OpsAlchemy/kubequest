Below is **SECTION 5** only.
Focused on **`kubectl auth can-i` — complete, correct usage with full examples and explanations**.
This is an **exam-critical debugging tool**.

---

# Section 5 — `kubectl auth can-i` (Deep, Correct, Practical)

---

## What `kubectl auth can-i` Actually Does

`kubectl auth can-i` answers **one question only**:

> **Does RBAC allow this subject to perform this action?**

It checks:

* Roles
* ClusterRoles
* RoleBindings
* ClusterRoleBindings

It does **NOT** check:

* Admission controllers
* PodSecurity
* Resource existence
* Runtime errors

If `can-i` says **yes** and action fails → RBAC is **not** the issue.

---

## 5.1 Basic Usage (Current User)

### Example 1 — Can I read pods?

```bash
kubectl auth can-i get pods
```

Explanation:

* Uses current kubeconfig identity
* Checks default namespace

---

### Example 2 — Explicit namespace

```bash
kubectl auth can-i list pods -n dev
```

Explanation:

* RBAC evaluation is **namespace-aware**
* Missing `-n` often causes confusion

---

## 5.2 Acting As Another Identity (`--as`)

### Example 3 — Acting as a User

```bash
kubectl auth can-i delete deployments \
  --as alice \
  -n prod
```

Explanation:

* `alice` must match **exact user name** from auth provider
* Namespace is mandatory for namespaced resources

---

### Example 4 — Acting as a ServiceAccount (CORRECT FORMAT)

```bash
kubectl auth can-i get pods \
  --as system:serviceaccount:default:my-sa \
  -n default
```

Explanation:

* ServiceAccount identity is **always expanded**
* Short names (`--as my-sa`) will not match

---

## 5.3 Common Mistake — Wrong ServiceAccount Identity

### ❌ Wrong

```bash
kubectl auth can-i get pods --as prometheus
```

### ✅ Correct

```bash
kubectl auth can-i get pods \
  --as system:serviceaccount:monitoring:prometheus \
  -n prod
```

Explanation:

* RBAC matches **full identity string**
* Namespace is part of identity

---

## 5.4 Checking Cluster-Scoped Resources

### Example 5 — Nodes (cluster-scoped)

```bash
kubectl auth can-i list nodes
```

Explanation:

* No namespace flag
* Requires ClusterRole + ClusterRoleBinding

---

### Example 6 — Namespaces

```bash
kubectl auth can-i get namespaces
```

Explanation:

* Namespaces are cluster-scoped
* RoleBinding can never grant this

---

## 5.5 Verb + Resource Accuracy (Exam Trap)

### Example 7 — Wrong resource name

```bash
kubectl auth can-i get deployment
```

Result:

```
no
```

### Correct

```bash
kubectl auth can-i get deployments.apps
```

Explanation:

* CLI uses **fully qualified resource**
* Same rule as `kubectl create role`

---

## 5.6 Subresource Checks

### Example 8 — Logs

```bash
kubectl auth can-i get pods/log -n debug
```

Explanation:

* `pods` permission ≠ `pods/log`
* This explains `kubectl logs` failures

---

### Example 9 — Exec

```bash
kubectl auth can-i create pods/exec -n dev
```

Explanation:

* `exec` uses `create` verb
* Very common exam trap

---

## 5.7 Listing Effective Permissions

### Example 10 — What can I do?

```bash
kubectl auth can-i --list
```

Explanation:

* Shows **all RBAC-allowed actions**
* Only for current user
* Namespaced output if `-n` is provided

---

### Example 11 — Namespace-specific listing

```bash
kubectl auth can-i --list -n prod
```

Explanation:

* Extremely useful to debug RoleBindings

---

## 5.8 Wildcard Checks (Debug Only)

### Example 12 — Full access check

```bash
kubectl auth can-i '*' '*'
```

Explanation:

* Indicates cluster-admin-like access
* Never use as justification for least privilege

---

## 5.9 ResourceNames Behavior

### Example 13 — Specific object access

```bash
kubectl auth can-i get secrets/db-creds -n finance
```

Explanation:

* Tests `resourceNames`
* `list` will still fail

---

### Example 14 — List still denied

```bash
kubectl auth can-i list secrets -n finance
```

Explanation:

* `resourceNames` blocks list
* Very common misunderstanding

---

## 5.10 Debug Flow Using `can-i` (Exam Pattern)

### Typical Exam Debug Steps

1. Test action:

```bash
kubectl auth can-i create pods -n dev
```

2. Test identity explicitly:

```bash
kubectl auth can-i create pods \
  --as system:serviceaccount:ci:ci-bot \
  -n dev
```

3. Test subresource if needed:

```bash
kubectl auth can-i create pods/exec -n dev
```

If all return **yes** → RBAC is correct.

---

## Section 5 — Hard Rules to Remember

* `can-i` checks **RBAC only**
* Always specify `-n` for namespaced resources
* ServiceAccount must use full identity string
* Subresources must be checked explicitly
* Cluster-scoped resources never use namespace
* `--list` is your RBAC truth view

---

Say **“section 6”** for **system users, nodes, and control-plane components**
or **“final cram”** for a **one-page RBAC exam summary**.
