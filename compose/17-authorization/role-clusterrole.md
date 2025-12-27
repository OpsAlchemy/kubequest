# RBAC Core Objects

## 1. Four Objects
- **Role**: Namespaced permissions definition
- **ClusterRole**: Cluster-wide permissions definition  
- **RoleBinding**: Grants namespace-scoped access
- **ClusterRoleBinding**: Grants cluster-wide access

## 2. Responsibility Split
**Permissions (WHAT)**: Role/ClusterRole  
**Scope (WHERE)**: Binding type determines namespace/global  
**Access (WHO)**: Binding links subjects to permissions

## 3. Key Rules
- No binding = no access
- Binding always decides scope
- RoleBinding always namespace-scoped
- ClusterRoleBinding always cluster-wide

---

# ClusterRole + RoleBinding - Critical Concept

## Core Principle
**Permissions come from Role/ClusterRole**  
**Scope comes from Binding type**

## Scope Matrix
| Role Type | Binding Type | Scope |
|-----------|--------------|-------|
| Role | RoleBinding | Single namespace |
| ClusterRole | RoleBinding | Single namespace |  
| ClusterRole | ClusterRoleBinding | Entire cluster |

## Why ClusterRole Exists
Avoid duplicating same Role across namespaces. ClusterRole can be:
- Bound cluster-wide (ClusterRoleBinding)
- Limited to namespace (RoleBinding)

## Gotcha: Cluster-Scoped Resources
If ClusterRole contains cluster-scoped resources (nodes, PVs):
- RoleBinding → IGNORES cluster-scoped permissions
- ClusterRoleBinding → Grants them globally

## Key Takeaway
**ClusterRole ≠ cluster-wide access**  
Binding type determines scope, not role type.



Below is **ONLY SECTION 2.1**.
Strictly about **scoping, namespaces, and what can / cannot reference what**.

---

# 2.1 Scoping Rules — Namespaced vs Cluster-Scoped (Very Important)

---

## Fundamental Rule

> **RBAC object scope is fixed and cannot be changed.**

Some objects are **namespaced**, some are **cluster-scoped**.
You cannot bend this rule.

---

## Which RBAC Objects Are Namespaced

These **belong to exactly one namespace**:

* `Role`
* `RoleBinding`
* `ServiceAccount`

You must specify `metadata.namespace` for them.

---

## Which RBAC Objects Are Cluster-Scoped

These **do not belong to any namespace**:

* `ClusterRole`
* `ClusterRoleBinding`

They have **no namespace field**.

---

## What This Means Practically

### Role

* Exists in **one namespace**
* Can only define permissions for:

  * Namespaced resources
* Cannot reference cluster-scoped resources (nodes, namespaces)

---

### RoleBinding

* Exists in **one namespace**
* Grants access **only inside that namespace**
* Can reference:

  * A Role (same namespace only)
  * A ClusterRole (global, but scope limited by RoleBinding namespace)

---

### ClusterRole

* Exists at cluster level
* Can define permissions for:

  * Namespaced resources
  * Cluster-scoped resources
* Has **no scope until bound**

---

### ClusterRoleBinding

* Exists at cluster level
* Grants access:

  * Across all namespaces
  * To cluster-scoped resources

---

## Namespace Crossing Rules (Critical)

### Can a RoleBinding reference a Role from another namespace?

❌ **No**

```yaml
roleRef:
  kind: Role
  name: some-role
```

That Role **must exist in the same namespace** as the RoleBinding.

---

### Can a RoleBinding reference a ClusterRole?

✅ **Yes**

```yaml
roleRef:
  kind: ClusterRole
  name: view
```

This is the **intended reuse pattern**.

---

### Can a RoleBinding grant access outside its namespace?

❌ **No**

Even if:

* Subject is a global User
* Subject is a Group
* Subject is a ServiceAccount from another namespace

Access is still limited to the RoleBinding namespace.

---

## ServiceAccount Namespace Rule (Important)

ServiceAccounts are namespaced identities.

This identity:

```
system:serviceaccount:monitoring:prometheus
```

* Belongs to `monitoring`
* Can be referenced in **any RoleBinding**
* Gets access **only in the RoleBinding namespace**

---

### Example: Cross-Namespace ServiceAccount Access

```yaml
kind: RoleBinding
metadata:
  namespace: production
subjects:
- kind: ServiceAccount
  name: prometheus
  namespace: monitoring
roleRef:
  kind: ClusterRole
  name: pod-reader
  apiGroup: rbac.authorization.k8s.io
```

Result:

* Prometheus SA can read pods in `production`
* Identity remains in `monitoring`

---

## Cluster-Scoped Resources vs RoleBinding (Exam Trap)

### Cluster-scoped resources:

* `nodes`
* `namespaces`
* `persistentvolumes`
* `clusterroles`
* `clusterrolebindings`

These **cannot** be granted using a RoleBinding.

This silently fails:

```yaml
rules:
- apiGroups: [""]
  resources: ["nodes"]
  verbs: ["get"]
```

Bound via RoleBinding → **ignored**

---

### Correct Way

You must use **ClusterRoleBinding**.

---

## How to Verify Scope Using CLI (Source of Truth)

### List All Resources With Scope

```bash
kubectl api-resources
```

Look at:

```
NAMESPACED
```

---

### Namespaced Only

```bash
kubectl api-resources --namespaced=true
```

### Cluster-Scoped Only

```bash
kubectl api-resources --namespaced=false
```

---

### RBAC-Specific Check

```bash
kubectl api-resources | grep -i role
```

Expected:

* roles → namespaced
* rolebindings → namespaced
* clusterroles → cluster-scoped
* clusterrolebindings → cluster-scoped

---

## Mental Locks for Section 2.1

* RoleBinding scope = its namespace
* Role must be in same namespace as RoleBinding
* ClusterRole can be reused anywhere
* RoleBinding cannot grant cluster-scoped resources
* `kubectl api-resources` is the authority

---

Say **“next”** when you want **Section 3 (examples: YAML + CLI mixes)**.
