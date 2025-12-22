Below are **clean notes** for this scenario, followed by an **updated one-page cheat sheet** with the new concepts folded in.
Reference-grade, no mistakes narrative, no restructuring fluff.

---

# Notes — PV/PVC Binding Using Labels and Node Affinity

---

## PersistentVolume with Node Affinity

When a volume is tied to a specific node filesystem (for example, `hostPath`), the PersistentVolume must explicitly declare **node affinity**.

Key points:

* `hostPath` volumes exist **only on a single node**
* `nodeAffinity` restricts which node can use the PV
* Pod scheduling must align with the node where the data exists
* Without node affinity, Kubernetes may attempt invalid scheduling

Relevant keys:

* `hostPath.path`
* `nodeAffinity.required.nodeSelectorTerms`

---

## Labels on PersistentVolumes

PersistentVolumes support **labels**, similar to Pods and Nodes.

Purpose:

* Enable **label-based PVC selection**
* Provide semantic grouping (tier, environment, class)

Example:

```yaml
metadata:
  labels:
    tier: white
```

Labels are **not required** for binding but allow controlled selection when multiple PVs exist.

---

## PVC Binding Using `selector.matchLabels`

A PersistentVolumeClaim can bind to a PV using **label selectors** instead of `volumeName`.

Key behavior:

* PVC searches for a PV with matching labels
* All standard binding rules still apply:

  * StorageClassName
  * AccessModes
  * Capacity
* More flexible than `volumeName`
* Useful when PV names are unknown or interchangeable

Example:

```yaml
selector:
  matchLabels:
    tier: white
```

---

## AccessModes Compatibility Rule

* PV access modes must **support** the PVC request
* `ReadWriteMany` requires a backend that supports multi-writer access
* Kubernetes does **not validate backend capability**
* Compatibility is enforced only at the API level

---

## StorageClass Role in Static Provisioning

When using a custom StorageClass with no dynamic provisioner:

* StorageClass acts as a **matching label**
* No storage is created automatically
* PV must already exist
* PVC binds only to PVs with the same `storageClassName`

---

## Binding Control Options Compared

| Method                 | Control Level | Flexibility |
| ---------------------- | ------------- | ----------- |
| `volumeName`           | Exact PV      | Lowest      |
| `selector.matchLabels` | Group-based   | Medium      |
| No selector            | Automatic     | Highest     |

---

## Mental Model

```
Node filesystem
 └── hostPath
      └── PersistentVolume (labels + nodeAffinity)
           └── PersistentVolumeClaim (selector)
```

---

# Updated One-Page Cheat Sheet (SC · PV · PVC)

---

## StorageClass (`storage.k8s.io/v1`)

| Key                    | Purpose                                |
| ---------------------- | -------------------------------------- |
| `provisioner`          | Defines dynamic or static provisioning |
| `volumeBindingMode`    | When binding occurs                    |
| `reclaimPolicy`        | PV lifecycle after PVC deletion        |
| `allowVolumeExpansion` | Allow PVC resize                       |

---

## PersistentVolume (`v1`)

| Key                             | Purpose                       |
| ------------------------------- | ----------------------------- |
| `capacity.storage`              | Total storage size            |
| `accessModes`                   | Supported access patterns     |
| `storageClassName`              | Links PV to StorageClass      |
| `persistentVolumeReclaimPolicy` | Retain/Delete behavior        |
| `hostPath`                      | Node filesystem storage       |
| `local`                         | Local disk volume             |
| `nodeAffinity`                  | Restricts usable nodes        |
| `labels`                        | Enable selector-based binding |
| `volumeMode`                    | Filesystem or block           |

---

## PersistentVolumeClaim (`v1`)

| Key                          | Purpose             |
| ---------------------------- | ------------------- |
| `accessModes`                | Requested access    |
| `resources.requests.storage` | Requested capacity  |
| `storageClassName`           | Select StorageClass |
| `volumeName`                 | Bind to exact PV    |
| `selector.matchLabels`       | Bind via PV labels  |
| `volumeMode`                 | Filesystem or block |

---

## Binding Rules (All Must Match)

* `storageClassName`
* AccessModes compatibility
* Requested size ≤ PV capacity
* Node affinity (for local/hostPath)
* Label selector (if specified)
* `volumeName` (if specified)

---

## Selector vs volumeName

| Feature             | `volumeName`  | `selector.matchLabels` |
| ------------------- | ------------- | ---------------------- |
| PV name required    | Yes           | No                     |
| Flexibility         | Low           | Medium                 |
| Multiple PV support | No            | Yes                    |
| Recommended for     | Exact binding | Tiered/static pools    |

---

## hostPath / local Volume Rules

* Node-specific storage
* Requires `nodeAffinity`
* Works best with `WaitForFirstConsumer`
* Not portable across nodes

---

## Lifecycle Flow

```
StorageClass
 → PersistentVolume (labels, nodeAffinity)
   → PersistentVolumeClaim (selector / volumeName)
     → Pod
```

---

If you want next:

* Add **Pod scheduling implications**
* Extend cheat sheet with **troubleshooting states (Pending / Bound)**
* Convert this into **printable A4 reference format**
