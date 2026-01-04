What you are observing is **expected Kubernetes behavior**.
Here is the precise explanation, clean and general.

---

## Why You Can Use a StorageClass That Does Not Appear as `standard`

In your cluster, the output shows:

```
local-path (default)
```

This means:

* **`local-path` is the default StorageClass**
* There is **no StorageClass named `standard`**
* Kubernetes does **not require** the default StorageClass to be named `standard`

---

## How Kubernetes Chooses a StorageClass

### Rule 1: Default StorageClass Is Selected by Annotation, Not Name

A StorageClass becomes default when it has this annotation:

```yaml
storageclass.kubernetes.io/is-default-class: "true"
```

In your cluster:

* `local-path` has this annotation
* Kubernetes treats it as the default

---

### Rule 2: PVC Without `storageClassName`

If a PVC is created like this:

```yaml
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
```

Kubernetes behavior:

* Automatically assigns **`local-path`**
* Storage is provisioned using `rancher.io/local-path`

This works even though:

* No `standard` StorageClass exists
* No StorageClass name was specified

---

### Rule 3: Explicit vs Implicit Usage

| PVC definition                 | StorageClass used      |
| ------------------------------ | ---------------------- |
| `storageClassName` omitted     | `local-path` (default) |
| `storageClassName: local-path` | `local-path`           |
| `storageClassName: standard`   | ❌ fails (not found)    |
| `storageClassName: ""`         | No StorageClass        |

---

## Why Many Docs Mention `standard`

* Many clusters name their default StorageClass `standard`
* This is **convention**, not a requirement
* Tools, labs, and examples often assume `standard`

Your cluster simply uses a different default name.

---

## Key Takeaway

* Kubernetes uses **default annotation**, not StorageClass name
* `standard` is not special
* `local-path` is your default StorageClass
* You can use storage without specifying a name because a default exists

---

## Quick Verification

```bash
kubectl get sc -o yaml | grep is-default
```

You will see:

```
storageclass.kubernetes.io/is-default-class: "true"
```

attached to `local-path`.

---

If you want, I can add:

* A one-line mental model for exams
* Difference between omitted vs empty `storageClassName`
* What happens if the default StorageClass is removed
