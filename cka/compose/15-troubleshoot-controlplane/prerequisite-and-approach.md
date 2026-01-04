# How to Approach Control Plane Issues

## Prerequisite Knowledge

* `/etc/kubernetes/manifests`
  Location of control plane **static pod** manifests.

---

## Places to Look for Logs

### Kubelet Logs

Use these when the kubelet itself is failing due to syntax errors, invalid flags, or startup issues.

```bash
journalctl -u kubelet
journalctl -u kubelet -n 100
journalctl -u kubelet -f
journalctl -u kubelet -b
journalctl -u kubelet -p err
journalctl -u kubelet --since "10 minutes ago"
```

To inspect kubelet service flags and configuration location:

```bash
systemctl cat kubelet
```

System logs (if applicable):

```bash
/var/log/syslog | grep <keyword>
```

---

### Static Pod Logs

Use these when the kubelet is running and able to create static pods, but the pods are crashing.

* Pod logs:

  * `/var/log/pods/`

    * `0.log` → current log
    * `1.log` → rotated log
* Container logs:

  * `/var/log/containers/`
  * This directory contains **symlinks** to pod logs.

---

### Container Runtime

Use these when the kubelet created the static pod but the container is failing.

```bash
crictl ps
crictl ps -a
crictl logs <container-id>
```

---

## Health and Probe Endpoints

### kube-apiserver

| Probe Type | Endpoint  | Port |
| ---------- | --------- | ---- |
| Startup    | `/livez`  | 6443 |
| Liveness   | `/livez`  | 6443 |
| Readiness  | `/readyz` | 6443 |

### etcd

| Probe Type | Endpoint  | Port |
| ---------- | --------- | ---- |
| Liveness   | `/health` | 2379 |
| Readiness  | `/health` | 2379 |

### kube-controller-manager

| Probe Type | Endpoint   | Port  |
| ---------- | ---------- | ----- |
| Liveness   | `/healthz` | 10257 |
| Readiness  | `/healthz` | 10257 |

### kube-scheduler

| Probe Type | Endpoint   | Port  |
| ---------- | ---------- | ----- |
| Liveness   | `/healthz` | 10259 |
| Readiness  | `/healthz` | 10259 |

### kubelet

| Endpoint   | Address           |
| ---------- | ----------------- |
| `/healthz` | `127.0.0.1:10248` |

---

## Key Component Ports

| Component      | Purpose      | Port  |
| -------------- | ------------ | ----- |
| kube-apiserver | API + health | 6443  |
| etcd           | Client API   | 2379  |
| kubelet        | Local health | 10248 |

---

## kube-apiserver Minimal Required Flags

* `--advertise-address=<node-ip>`
* `--secure-port=6443`
* `--etcd-servers=https://127.0.0.1:2379`

---

## TLS Certificate Paths (Do Not Invent)

### API Server

```
/etc/kubernetes/pki/apiserver.crt
/etc/kubernetes/pki/apiserver.key
/etc/kubernetes/pki/ca.crt
```

### etcd

```
/etc/kubernetes/pki/etcd/ca.crt
/etc/kubernetes/pki/etcd/server.crt
/etc/kubernetes/pki/etcd/server.key
```

If these files exist, do **not** modify them.

---


