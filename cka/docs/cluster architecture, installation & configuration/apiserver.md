# Kubernetes Control Plane (kubeadm)

## 1. Where kubeadm control plane manifests live

**Source of truth for control-plane pods:**

```sh
/etc/kubernetes/manifests/
```

Contains static pod manifests for:

* kube-apiserver
* kube-controller-manager
* kube-scheduler
* etcd

These are **file-based**, not API-created objects.

---

## 2. kubelet is the first and most important service

**Startup order (simplified):**

1. systemd starts `kubelet`
2. kubelet watches:

   ```sh
   /etc/kubernetes/manifests
   ```
3. kubelet **creates static pods directly via the container runtime**
4. kube-apiserver comes up
5. API-based workloads start only after that

Key insight:

> **The entire control plane is bootstrapped by kubelet reading files, not the API**

If kubelet is down → no control plane.

---

## 3. Static pod lifecycle (very important)

### If kube-apiserver manifest is valid:

* Container starts
* Writes logs
* Registers with etcd

### If flags are wrong (but YAML is valid):

* Pod is created
* Container starts
* Process crashes
* Logs appear in `0.log` / `1.log`

### If manifest YAML is invalid:

* kubelet **refuses to create the pod**
* Error appears in **kubelet logs**
* No container logs exist

This distinction matters during debugging.

---

## 4. Log directories and what they mean

### `/var/log/pods` – source of truth

Structure:

```sh
/var/log/pods/<namespace>_<pod>_<uid>/<container>/
```

Example:

```sh
/var/log/pods/kube-system_kube-apiserver-controlplane_<uid>/kube-apiserver/
  ├── 0.log   (current)
  └── 1.log   (previous)
```

Rules:

* `0.log` → what the container is writing **right now**
* `1.log` → last terminated / crashed instance

Log rotation happens when:

* container restarts
* file size limit reached

---

### `/var/log/containers` – convenience layer

* Contains **symlinks**, not real logs
* Points to files under `/var/log/pods`

Example:

```sh
kube-apiserver-<id>.log -> /var/log/pods/.../kube-apiserver/0.log
```

Rule:

* symlink → `0.log` = current container
* symlink → `1.log` = previous container

This is what `kubectl logs` reads.

---

## 5. Container runtime inspection

Depending on runtime:

### containerd (most kubeadm clusters)

```bash
crictl ps
crictl logs <container-id>
```

### Docker (older clusters)

```bash
docker ps
docker logs <container-id>
```

If the pod exists but crashes:

* you **will** see it here

If kubelet never created the pod:

* you **will not**

---

## 6. kubelet logs (authoritative for node-side failures)

### Primary source (systemd-based nodes)

```bash
journalctl -u kubelet
```

Most useful variants:

```bash
journalctl -u kubelet -n 100
journalctl -u kubelet -f
journalctl -u kubelet -b
journalctl -u kubelet -p err
journalctl -u kubelet --since "10 minutes ago"
```

What kubelet logs tell you:

* static pod parse errors
* container creation failures
* API server reachability
* node registration failures

---

## 7. kubelet configuration (what actually runs)

### How kubelet is started

```bash
systemctl cat kubelet
```

Important flags to confirm:

* `--config=/var/lib/kubelet/config.yaml`
* `--kubeconfig=/etc/kubernetes/kubelet.conf`

### kubelet config file

```bash
cat /var/lib/kubelet/config.yaml
```

Common real-world issues:

* wrong cgroup driver
* bad container runtime endpoint
* invalid cert paths

---

## 8. Example: interpreting kubelet errors (trimmed)

Representative kubelet log pattern (middle omitted):

```
E... Failed to get Node status
Get "https://<api-server>:6443/..."
E... Unable to register node with API server
I... Attempting to register node
E... No need to create mirror pod, since failed to get node info
```

Meaning:

* kubelet is healthy
* kubelet cannot talk to API server
* API server is unhealthy or unreachable
* usually caused by **etcd failure**

---

## 9. Debugging rule of thumb (critical)

| Symptom                | Where to look           |
| ---------------------- | ----------------------- |
| Static pod not created | kubelet logs            |
| Pod exists but crashes | `/var/log/pods/*/0.log` |
| API server errors      | kube-apiserver logs     |
| API server can’t start | etcd logs               |
| Node not Ready         | kubelet → apiserver     |

---

## 10. Key mental model (final)

> kubelet reads files
> kubelet creates control plane pods
> control plane enables the API
> everything else depends on that

If you remember **only one thing**:

> **If the API server is broken, kubelet logs explain why — but etcd logs explain the root cause**

---

