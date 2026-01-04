# etcd Snapshot Backup and Restore (kubeadm)
```sh
export ETCDCTL_API=3
ETCDCTL_API=3 etcdctl snapshot save /opt/etcd-backup.db \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key

etcdctl snapshot status /opt/etcd-backup.db

systemctl stop kubelet

ETCDCTL_API=3 etcdctl snapshot restore /opt/etcd-backup.db \
  --data-dir=/var/lib/etcd-from-backup


vi /etc/kubernetes/manifests/etcd.yaml
change - --data-dir

systemctl start kubelet
```

---

### Snapshot Save (etcdctl v3)

```bash
ETCDCTL_API=3 etcdctl snapshot save /opt/cluster_backup.db \
  --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key
```

* etcd in kubeadm uses **its own PKI**
* Required certificate paths are always under:

  ```
  /etc/kubernetes/pki/etcd/
  ```
* Snapshot file is created as a single `.db` file
* Snapshot save does not modify running etcd data

---

### Snapshot Restore (Logical Restore)

```bash
ETCDCTL_API=3 etcdctl snapshot restore /opt/cluster_backup.db \
  --data-dir=/root/default.etcd
```

* Restore always writes into a **new, empty directory**
* Restore operation is **offline** and does not contact a running etcd
* Output logs are written to **stderr**
* Restored data structure includes:

  ```
  <data-dir>/member/
  ```

---

### Capturing Restore Logs

```bash
ETCDCTL_API=3 etcdctl snapshot restore /opt/cluster_backup.db \
  --data-dir=/root/default.etcd \
  2>&1 | tee restore.txt
```

* etcdctl logs are emitted to stderr
* `2>&1` is required to capture logs using `tee`

---

### Restored Data Location

```text
/root/default.etcd/
└── member/
    ├── wal/
    └── snap/
```

* This directory contains the restored etcd state
* It is not used until etcd is explicitly pointed to it

---

### Switching etcd to Use Restored Data

File:

```text
/etc/kubernetes/manifests/etcd.yaml
```

Change:

```yaml
- --data-dir=/var/lib/etcd
```

To:

```yaml
- --data-dir=/root/default.etcd
```

* kubelet reconciles the static pod
* etcd restarts using restored state

---

### Verification

```bash
kubectl get nodes
kubectl get pods -A
```

* API server availability confirms successful restore

---

### Key Facts to Memorize

* etcd snapshot restore never overwrites existing data
* Restore creates a new etcd member state
* kubelet restart is required to activate restored data
* etcd data lives on the control-plane node filesystem
* TLS flags are mandatory for snapshot save in kubeadm

---
