# Namespacing ClusterRoles Using RoleBindings


---

### Context

There is an existing namespace `applications`.

User `smoke` must:

* Create and delete Pods, Deployments, and StatefulSets only in namespace `applications`
* Have read-only (view) access in all namespaces except `kube-system`

Verification must be done using `kubectl auth can-i`.

---

### Core Learning (Must Understand)

RBAC has two independent dimensions.

Permissions come from:

* Role
* ClusterRole

Scope comes from:

* RoleBinding
* ClusterRoleBinding

Key rule:

A ClusterRole becomes namespace-scoped when it is bound using a RoleBinding.

Kubernetes RBAC has no deny rules. Access is controlled by where bindings exist.

---

### Resource Names and API Groups (Critical for Exams)

Pods

```text
pods
```

Deployments

```text
deployments.apps
```

StatefulSets

```text
statefulsets.apps
```

Services

```text
services
```

ConfigMaps

```text
configmaps
```

Secrets

```text
secrets
```

Jobs

```text
jobs.batch
```

CronJobs

```text
cronjobs.batch
```

Using the wrong API group silently breaks permissions.

---

### How to Create Roles for Different Resources (Examples)

Pods only (create, delete)

```
kubectl -n applications create role pod-writer \
  --verb=create,delete \
  --resource=pods
```

Deployments only (create, delete)

```
kubectl -n applications create role deployment-writer \
  --verb=create,delete \
  --resource=deployments.apps
```

StatefulSets only (create, delete)

```
kubectl -n applications create role sts-writer \
  --verb=create,delete \
  --resource=statefulsets.apps
```

Multiple resources in one Role

```
kubectl -n applications create role workload-writer \
  --verb=create,delete \
  --resource=pods,deployments.apps,statefulsets.apps
```

Read-only Role (explicit verbs)

```
kubectl -n applications create role workload-reader \
  --verb=get,list,watch \
  --resource=pods,deployments.apps,statefulsets.apps
```

---

### Step 1: Required Role for User smoke

Single Role covering Pods, Deployments, StatefulSets.

```
kubectl -n applications create role smoke \
  --verb=create,delete \
  --resource=pods,deployments.apps,statefulsets.apps
```

Bind it to user `smoke`.

```
kubectl -n applications create rolebinding smoke \
  --role=smoke \
  --user=smoke
```

Effect:

* Write access only inside `applications`
* No access elsewhere

---

### Step 2: View Access in All Namespaces Except kube-system

Use built-in ClusterRole `view`, bound per namespace.

```
kubectl -n default create rolebinding smoke-view \
  --clusterrole=view \
  --user=smoke

kubectl -n applications create rolebinding smoke-view \
  --clusterrole=view \
  --user=smoke

kubectl -n kube-public create rolebinding smoke-view \
  --clusterrole=view \
  --user=smoke

kubectl -n kube-node-lease create rolebinding smoke-view \
  --clusterrole=view \
  --user=smoke
```

No binding is created in `kube-system`.

---

### Verification Commands

applications namespace

```
kubectl auth can-i create deployments --as smoke -n applications
kubectl auth can-i delete pods --as smoke -n applications
kubectl auth can-i delete statefulsets --as smoke -n applications
kubectl auth can-i delete secrets --as smoke -n applications
```

Expected

```
yes
yes
yes
no
```

View access

```
kubectl auth can-i list pods --as smoke -n default
kubectl auth can-i list pods --as smoke -n applications
kubectl auth can-i list pods --as smoke -n kube-public
kubectl auth can-i list pods --as smoke -n kube-node-lease
kubectl auth can-i list pods --as smoke -n kube-system
```

Expected

```
yes
yes
yes
yes
no
```

---

### Common RBAC Mistakes (Learn Once)

* Using `deployments` instead of `deployments.apps`
* Expecting ClusterRole to be cluster-wide without ClusterRoleBinding
* Trying to deny access (not supported)
* Binding a Role across namespaces (not possible)
* Forgetting StatefulSets live in `apps` API group

---
