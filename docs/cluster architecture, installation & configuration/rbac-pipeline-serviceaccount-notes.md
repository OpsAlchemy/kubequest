# Kubernetes RBAC: Pipeline ServiceAccount with Cluster-Wide Read and Namespaced Deployment Management

---

## Problem Statement

There are two existing Namespaces: `ns1` and `ns2`.

Requirements:

* Create a ServiceAccount named `pipeline` in **both namespaces**
* These ServiceAccounts must:

  * View almost everything **cluster-wide** (read-only)
  * Create and delete **Deployments only in their own Namespace**
  * Not update Deployments
  * Not modify resources in other Namespaces
* All permissions must be verifiable using `kubectl auth can-i`

---

## RBAC Concepts (Exam-Critical)

### RBAC Objects

* **Role**

  * Namespace-scoped
  * Defines permissions usable only inside one Namespace

* **ClusterRole**

  * Cluster-scoped
  * Defines permissions usable across the whole cluster

* **RoleBinding**

  * Namespace-scoped binding
  * Applies a Role or ClusterRole **inside one Namespace**

* **ClusterRoleBinding**

  * Cluster-scoped binding
  * Applies a ClusterRole **cluster-wide**

---

### Valid RBAC Combinations

| Role Type   | Binding Type       | Result                           |
| ----------- | ------------------ | -------------------------------- |
| Role        | RoleBinding        | Namespaced permissions           |
| ClusterRole | ClusterRoleBinding | Cluster-wide permissions         |
| ClusterRole | RoleBinding        | Namespaced usage of cluster role |
| Role        | ClusterRoleBinding | Invalid (not allowed)            |

---

## Design Approach

1. **Cluster-wide read access**

   * Use built-in ClusterRole `view`
   * Bind using ClusterRoleBinding

2. **Namespaced write access**

   * Use a custom ClusterRole for `deployments`
   * Bind using RoleBinding per namespace

This ensures:

* Least privilege
* Clear separation of scope
* Exam-safe RBAC model

---

## Final Resource Naming

| Resource Type      | Name                          |
| ------------------ | ----------------------------- |
| ServiceAccount     | `pipeline`                    |
| ClusterRole        | `pipeline-deployment-manager` |
| RoleBinding        | `pipeline-deployment-manager` |
| ClusterRoleBinding | `pipeline-view`               |

---

## Step 1: Create ServiceAccounts

```
kubectl create serviceaccount pipeline -n ns1
kubectl create serviceaccount pipeline -n ns2
```

---

## Step 2: Grant Cluster-Wide Read Access

The default ClusterRole `view` already exists.

```
kubectl get clusterrole view
```

Bind it to both ServiceAccounts:

```
kubectl create clusterrolebinding pipeline-view \
  --clusterrole=view \
  --serviceaccount=ns1:pipeline \
  --serviceaccount=ns2:pipeline
```

Effect:

* Read access to most resources
* No access to Secrets
* No write permissions

---

## Step 3: Create Deployment Management ClusterRole

This ClusterRole allows **create** and **delete** only.

```
kubectl create clusterrole pipeline-deployment-manager \
  --verb=create,delete \
  --resource=deployments.apps
```

Notes:

* `deployments.apps` is the correct API resource
* `update` is intentionally excluded

---

## Step 4: Bind Deployment Permissions Per Namespace

Bind the ClusterRole **inside each Namespace**.

```
kubectl create rolebinding pipeline-deployment-manager \
  --clusterrole=pipeline-deployment-manager \
  --serviceaccount=ns1:pipeline \
  -n ns1
```

```
kubectl create rolebinding pipeline-deployment-manager \
  --clusterrole=pipeline-deployment-manager \
  --serviceaccount=ns2:pipeline \
  -n ns2
```

Effect:

* ns1 pipeline → manage deployments only in ns1
* ns2 pipeline → manage deployments only in ns2

---

## Permission Matrix (Effective Result)

| Action             | Namespace       | Allowed |
| ------------------ | --------------- | ------- |
| create deployments | own namespace   | yes     |
| delete deployments | own namespace   | yes     |
| update deployments | any             | no      |
| create deployments | other namespace | no      |
| list pods          | cluster-wide    | yes     |
| list deployments   | cluster-wide    | yes     |
| list secrets       | cluster-wide    | no      |

---

## Verification Commands

### ns1 ServiceAccount

```
kubectl auth can-i create deployments \
  --as system:serviceaccount:ns1:pipeline -n ns1

kubectl auth can-i delete deployments \
  --as system:serviceaccount:ns1:pipeline -n ns1

kubectl auth can-i update deployments \
  --as system:serviceaccount:ns1:pipeline -n ns1

kubectl auth can-i create deployments \
  --as system:serviceaccount:ns1:pipeline -n ns2
```

Expected:

```
yes
yes
no
no
```

---

### Cluster-Wide Read Checks

```
kubectl auth can-i list deployments \
  --as system:serviceaccount:ns1:pipeline -A

kubectl auth can-i list pods \
  --as system:serviceaccount:ns2:pipeline -A

kubectl auth can-i list secrets \
  --as system:serviceaccount:ns2:pipeline -A
```

Expected:

```
yes
yes
no
```

---
