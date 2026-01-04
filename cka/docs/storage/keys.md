Below is **clean, general, reference-grade notes** explaining **each spec key only**, grouped by object type.
No narrative, no mistakes, no exam framing — suitable for long-term notes.

---

# Kubernetes Storage Objects – Spec Key Reference Notes

---

## StorageClass (`storage.k8s.io/v1`)

### `provisioner`

Defines **who creates the storage**.

* Dynamic provisioner
  Example:

  ```
  rancher.io/local-path
  kubernetes.io/aws-ebs
  disk.csi.azure.com
  ```

* No provisioner (static provisioning)

  ```
  kubernetes.io/no-provisioner
  ```

Meaning:

* With a real provisioner → storage is created dynamically
* With `no-provisioner` → PVs must already exist

---

### `volumeBindingMode`

Controls **when PV–PVC binding occurs**.

Values:

* `Immediate`

  * PVC binds as soon as it is created
  * Node placement is ignored
* `WaitForFirstConsumer`

  * Binding is delayed until a Pod uses the PVC
  * Ensures node-aware scheduling (required for `local` volumes)

---

### `reclaimPolicy`

Controls what happens to the **PV after PVC deletion**.

Values:

* `Delete` – underlying storage is deleted
* `Retain` – PV remains, data is preserved

---

### `allowVolumeExpansion`

Controls whether PVC size can be increased.

Values:

* `true`
* `false`

---

## PersistentVolume (`v1`)

### `capacity`

Defines **total storage size** of the PV.

Example:

```yaml
capacity:
  storage: 100Mi
```

---

### `accessModes`

Defines **how the volume can be mounted**.

Common values:

* `ReadWriteOnce (RWO)`
* `ReadOnlyMany (ROX)`
* `ReadWriteMany (RWX)`

Must be **compatible** with PVC access modes.

---

### `storageClassName`

Associates the PV with a StorageClass.

Rules:

* Must match PVC `storageClassName`
* Empty value means “no storage class”

---

### `persistentVolumeReclaimPolicy`

Defines lifecycle behavior after PVC deletion.

Values:

* `Retain`
* `Delete`
* `Recycle` (deprecated)

---

### `hostPath`

Maps storage to a **path on the node filesystem**.

Example:

```yaml
hostPath:
  path: /opt/blue-data-cka
```

Characteristics:

* Node-specific
* Not suitable for multi-node production
* Common for local testing or static local volumes

---

### `local`

Defines a **local disk volume**.

Example:

```yaml
local:
  path: /opt/blue-data-cka
```

Notes:

* Requires `nodeAffinity`
* Works only with `WaitForFirstConsumer`

---

### `nodeAffinity`

Restricts which node can use the PV.

Example:

```yaml
nodeAffinity:
  required:
    nodeSelectorTerms:
    - matchExpressions:
      - key: kubernetes.io/hostname
        operator: In
        values:
        - controlplane
```

Purpose:

* Ensures Pod scheduling matches the node where storage exists

---

## PersistentVolumeClaim (`v1`)

### `accessModes`

Requested access mode.

Rules:

* Must be a **subset** of PV access modes
* Must match at least one compatible PV

---

### `resources.requests.storage`

Defines **requested storage size**.

Example:

```yaml
resources:
  requests:
    storage: 50Mi
```

Rules:

* Requested size ≤ PV capacity

---

### `storageClassName`

Selects which StorageClass to use.

Rules:

* Must match PV `storageClassName`
* If omitted:

  * Default StorageClass is used (if exists)

---

### `volumeName`

Forces binding to a **specific PV**.

Example:

```yaml
volumeName: blue-pv-cka
```

Behavior:

* Skips normal PV selection
* PVC binds only to the named PV

---

### `volumeMode`

Defines how the volume is exposed.

Values:

* `Filesystem` (default)
* `Block`

---

## Relationship Summary (Mental Model)

```
StorageClass
 └── defines provisioning + binding behavior

PersistentVolume
 └── defines actual storage + node placement

PersistentVolumeClaim
 └── requests storage and binds to a PV
```

Binding requires:

* Matching `storageClassName`
* Compatible `accessModes`
* Sufficient `capacity`
* Node compatibility (for local volumes)

---

If you want next:

* A **one-page cheat sheet**
* A **PV–PVC binding flow diagram**
* Notes extended to **Pod volume usage**

Say what to add, and I will extend without restructuring.
