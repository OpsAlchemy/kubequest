Below is a **single-page, compact cheat sheet**.
Dense, reference-grade, no narrative, no examples beyond what is necessary.

---

# Kubernetes Storage (SC · PV · PVC) — One-Page Cheat Sheet

---

## StorageClass (`storage.k8s.io/v1`)

| Key                    | Purpose                        | Notes                                                |
| ---------------------- | ------------------------------ | ---------------------------------------------------- |
| `provisioner`          | Who creates storage            | `kubernetes.io/no-provisioner` → static provisioning |
| `volumeBindingMode`    | When PV binds to PVC           | `Immediate` | `WaitForFirstConsumer`                 |
| `reclaimPolicy`        | PV behavior after PVC deletion | `Delete` | `Retain`                                  |
| `allowVolumeExpansion` | Allow PVC resize               | Requires CSI support                                 |

---

## PersistentVolume (`v1`)

| Key                             | Purpose                    | Notes                  |
| ------------------------------- | -------------------------- | ---------------------- |
| `capacity.storage`              | Total size of PV           | Must be ≥ PVC request  |
| `accessModes`                   | How volume can be mounted  | `RWO`, `ROX`, `RWX`    |
| `storageClassName`              | Links PV to StorageClass   | Must match PVC         |
| `persistentVolumeReclaimPolicy` | Lifecycle after PVC delete | `Retain` most common   |
| `hostPath`                      | Node filesystem path       | Node-specific          |
| `local`                         | Local disk volume          | Requires node affinity |
| `nodeAffinity`                  | Restrict node usage        | Mandatory for `local`  |
| `volumeMode`                    | Filesystem or block        | `Filesystem` default   |

---

## PersistentVolumeClaim (`v1`)

| Key                          | Purpose             | Notes                      |
| ---------------------------- | ------------------- | -------------------------- |
| `accessModes`                | Requested access    | Must be compatible with PV |
| `resources.requests.storage` | Requested size      | ≤ PV capacity              |
| `storageClassName`           | Select StorageClass | Uses default if omitted    |
| `volumeName`                 | Force specific PV   | Skips PV matching logic    |
| `volumeMode`                 | Filesystem or block | Must match PV              |

---

## Binding Rules (Must Match)

* `storageClassName`
* Compatible `accessModes`
* Requested size ≤ PV `capacity`
* Node affinity (for local volumes)
* `volumeName` (if specified) must exist

---

## volumeBindingMode Behavior

| Mode                   | Binding Time          | Node Awareness |
| ---------------------- | --------------------- | -------------- |
| `Immediate`            | On PVC creation       | No             |
| `WaitForFirstConsumer` | When Pod is scheduled | Yes            |

---

## Provisioning Models

| Model   | Provisioner                    | PV Creation |
| ------- | ------------------------------ | ----------- |
| Static  | `kubernetes.io/no-provisioner` | Manual      |
| Dynamic | CSI / in-tree                  | Automatic   |

---

## Lifecycle Flow

```
StorageClass → PersistentVolume → PersistentVolumeClaim → Pod
```

---

## Key Immutability Rules

* PVC spec is immutable after creation
  (except `resources.requests.storage`)
* Change `volumeName`, `storageClassName`, `accessModes` → recreate PVC

---

## Common Defaults

* `volumeMode`: Filesystem
* `accessModes`: ReadWriteOnce
* `volumeBindingMode`: Immediate (unless overridden)

---

If you want, I can now:

* Add **Pod volume usage** to this page
* Produce a **visual flow diagram**
* Create a **CKA-speed checklist** (what to check in 30 seconds)
