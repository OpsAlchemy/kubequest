# Manual StorageClass

A `manual` StorageClass is commonly used to represent **static provisioning** in Kubernetes.

Key characteristics:

* **No dynamic provisioning**

  * Kubernetes will not create storage automatically.
  * PersistentVolumes must be **created in advance** by an administrator.

* **Explicit control over storage**

  * The administrator defines:

    * Capacity
    * Access modes
    * Reclaim policy
    * Backend storage details
  * PersistentVolumeClaims request storage from these predefined volumes.

* **Binding is deterministic**

  * A PVC binds only when:

    * `storageClassName` matches
    * Access modes are compatible
    * Requested size is less than or equal to PV capacity
  * Optional use of `volumeName` enforces binding to a specific PV.

* **Typical use cases**

  * On-premises or bare-metal environments
  * Local disks or manually managed NFS shares
  * Environments where storage lifecycle is managed outside Kubernetes
  * Scenarios requiring strict control over which volume is consumed

---

### Static Provisioning Model

With a manual StorageClass:

* **PV lifecycle** is independent of PVC creation
* **Storage is provisioned first**, then claimed
* Kubernetes acts as a **scheduler and binder**, not a storage creator

This contrasts with dynamic provisioning, where Kubernetes requests storage from an external provisioner when a PVC is created.

---

### Key Takeaway

The `manual` StorageClass represents a **deliberate, administrator-managed storage model** where:

* Storage exists beforehand
* Kubernetes only handles matching and binding
* Volume ownership and lifecycle are explicitly controlled


https://kubernetes.io/docs/tasks/configure-pod-container/configure-persistent-volume-storage/