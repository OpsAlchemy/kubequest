# Custom Resource Definitions (CRDs) and Custom Resources (CRs)

---

## What CRDs and CRs are

* **CustomResourceDefinition (CRD)** extends the Kubernetes API by defining a new resource type
* **Custom Resource (CR)** is an instance of that resource type
* CRDs are created **once**
* CRs are created **many times**
* A CR **cannot exist** unless its CRD already exists
* CRDs are always **cluster-scoped**
* CRs can be **namespaced or cluster-scoped**, depending on the CRD

Analogy:

* Deployment API → Deployment objects
* CRD → Custom API
* CR → Objects using that API

---

## Core identity of any Kubernetes resource

Every Kubernetes resource is uniquely identified by:

```
group + version + kind
```

Examples:

```yaml
apiVersion: apps/v1
kind: Deployment
```

```yaml
apiVersion: storage.example.com/v1
kind: Backup
```

---

## Minimal CRD structure (exam-ready, v1)

> With `apiextensions.k8s.io/v1`, a schema is **mandatory**.

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: <plural>.<group>
spec:
  group: <group>
  scope: Namespaced | Cluster
  names:
    plural: <plural>
    singular: <singular>
    kind: <Kind>
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
```

Critical rules:

```
metadata.name = plural.group
Exactly one version must have storage: true
At least one version must have served: true
```

---

## Meaning of CRD fields

1. **group**
   - Logical API grouping
   - Used in CRD and CR `apiVersion`

2. **version**
   - API version
   - Appears after `/` in `apiVersion`

3. **kind**
   - Singular, capitalized resource name
   - Used in CR YAML

4. **plural**
   - Used in `kubectl` commands

5. **singular**
   - Optional `kubectl` usage

6. **scope**
   - Determines whether CRs are namespaced or cluster-scoped

---

## `served` and `storage` (exam-critical)

### served

```yaml
served: true
```

* Determines whether this version is accessible via the API
* If `false`, users **cannot** create or read CRs using this version

Mental model:

```
served = can users use this version?
```

---

### storage

```yaml
storage: true
```

* Determines which version is used to store objects in **etcd**
* Exactly **one** version must be `storage: true`
* Other served versions are automatically converted to this version

Mental model:

```
storage = how Kubernetes stores the object internally
```

---

## Namespaced vs Cluster scope

### Namespaced CRD

* CR must include `metadata.namespace`
* kubectl supports `-n` and `-A`

Example CR:

```yaml
metadata:
  name: daily-backup
  namespace: default
```

Commands:

```bash
kubectl get backups -n default
kubectl get backups -A
```

---

### Cluster-scoped CRD

* CR must NOT include `metadata.namespace`
* kubectl does NOT support `-n` or `-A`

Example CR:

```yaml
metadata:
  name: sunday-window
```

---

## Example 1: Namespaced CRD (Backup)

### CustomResourceDefinition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: backups.storage.example.com
spec:
  group: storage.example.com
  scope: Namespaced
  names:
    plural: backups
    singular: backup
    kind: Backup
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
```

Create and verify:

```bash
kubectl apply -f backup-crd.yaml
kubectl get crd backups.storage.example.com
```

---

Custom Resource

```yaml
apiVersion: storage.example.com/v1
kind: Backup
metadata:
  name: daily-backup
  namespace: default
```

---

## Example 2: Cluster-scoped CRD (MaintenanceWindow)

### CustomResourceDefinition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: maintenancewindows.ops.example.com
spec:
  group: ops.example.com
  scope: Cluster
  names:
    plural: maintenancewindows
    singular: maintenancewindow
    kind: MaintenanceWindow
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
```
Custom Resource

```yaml
apiVersion: ops.example.com/v1
kind: MaintenanceWindow
metadata:
  name: example-maintenancewindow
```
---

## Example 3: Namespaced CRD with operational intent (ScheduledBackup)

This example models scheduled backups with retention and demonstrates validation.

### CustomResourceDefinition

```yaml
apiVersion: apiextensions.k8s.io/v1
kind: CustomResourceDefinition
metadata:
  name: scheduledbackups.storage.example.com
spec:
  group: storage.example.com
  scope: Namespaced
  names:
    plural: scheduledbackups
    singular: scheduledbackup
    kind: ScheduledBackup
  versions:
    - name: v1
      served: true
      storage: true
      schema:
        openAPIV3Schema:
          type: object
          properties:
            spec:
              type: object
              required:
                - schedule
                - retention
              properties:
                schedule:
                  type: string
                retention:
                  type: object
                  required:
                    - days
                  properties:
                    days:
                      type: integer
                      minimum: 1
```

Custom Resource

```yaml
apiVersion: storage.example.com/v1
kind: ScheduledBackup
metadata:
  name: daily-backup
  namespace: default
spec:
  schedule: "0 2 * * *"
  retention:
    days: 7
```
---

## Adding shortcuts with `shortNames`

Shortcuts make kubectl usage faster.

### How to add
CR
```yaml
names:
  plural: featuretoggles
  singular: featuretoggle
  kind: FeatureToggle
  shortNames:
    - ft
```

### Usage

```bash
kubectl get ft
kubectl describe ft generic -n default
kubectl delete ft generic -n default
```

Short names are:

* Defined **only in the CRD**
* Optional
* Very useful in the exam

---

## Creating Custom Resources (CRs)

Rules:

* CRD must exist first
* CR `apiVersion` must match CRD group/version
* CR `kind` must match CRD kind exactly
* Namespace must match scope

Command:

```bash
kubectl apply -f cr.yaml
```

---

## Listing, describing, deleting CRs

```bash
kubectl get <plural>
kubectl describe <singular> <name> -n <namespace>
kubectl delete <singular> <name> -n <namespace>
```

---

## Order of operations (exam critical)

Correct:

1. Create CRD
2. Verify CRD exists
3. Create CR

Incorrect:

* Creating CR before CRD

Error:

```text
no matches for kind "<Kind>" in version "<group>/<version>"
```

---

## kubectl mental model

* `kubectl get` → **plural**
* YAML `kind` → **Kind**
* YAML `apiVersion` → **group/version**
* CRD name → **plural.group**

---

## Common CKA mistakes

* Missing schema in v1 CRDs
* Wrong CRD name (not plural.group)
* apiVersion mismatch in CR
* Namespace used on cluster-scoped CR
* Missing namespace on namespaced CR
* Using singular with `kubectl get`
* Creating CR before CRD

---

## Final exam checklist

* CRD applied successfully
* Schema present for v1 CRDs
* metadata.name = plural.group
* Exactly one `storage: true`
* At least one `served: true`
* Scope respected
* Correct plural used in kubectl commands
