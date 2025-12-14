# Kubernetes Probes & Health Endpoints

---

## 1. Probe Endpoints by Component (Primary Reference)

### Control Plane Components

#### kube-apiserver

| Probe type | Endpoint  | Port |
| ---------- | --------- | ---- |
| Startup    | `/livez`  | 6443 |
| Liveness   | `/livez`  | 6443 |
| Readiness  | `/readyz` | 6443 |

---

#### etcd

| Probe type | Endpoint  | Port |
| ---------- | --------- | ---- |
| Liveness   | `/health` | 2379 |
| Readiness  | `/health` | 2379 |

---

#### kube-controller-manager

| Probe type | Endpoint   | Port  |
| ---------- | ---------- | ----- |
| Liveness   | `/healthz` | 10257 |
| Readiness  | `/healthz` | 10257 |

---

#### kube-scheduler

| Probe type | Endpoint   | Port  |
| ---------- | ---------- | ----- |
| Liveness   | `/healthz` | 10259 |
| Readiness  | `/healthz` | 10259 |

---

#### kubelet

| Health endpoint | Address           |
| --------------- | ----------------- |
| `/healthz`      | `127.0.0.1:10248` |

Notes:

* kubelet is not a pod
* probes do not apply

---

#### kube-proxy

* No guaranteed HTTP health endpoint
* Health inferred from process state
* `/healthz` may exist but is implementation-specific

---

## 2. Port Cheat Sheet (Memorize)

| Component      | Purpose      | Port  |
| -------------- | ------------ | ----- |
| kube-apiserver | API + health | 6443  |
| etcd           | Client API   | 2379  |
| kubelet        | Local health | 10248 |

---

## 3. Failure Symptom Mapping (Fast Diagnosis)

| Symptom                        | Meaning                            |
| ------------------------------ | ---------------------------------- |
| `crictl ps` shows no apiserver | YAML or kubelet error              |
| Container exits immediately    | Invalid flag                       |
| Running but NotReady           | Dependency failure (usually etcd)  |
| CrashLoopBackOff               | Liveness failure or repeated exits |
| `connection refused :6443`     | API server down                    |
| `connection refused :2379`     | etcd misconfigured                 |

---

## 4. One-Line Exam Rules

* kube-apiserver uses `/livez` and `/readyz`
* everything else uses `/healthz`
* readiness failure does not restart containers
* liveness failure does restart containers
* apiserver NotReady usually means etcd

---

## 5. What Probes Are

Probes are checks executed by kubelet against containers to determine:

* whether the process is alive
* whether it is ready to serve traffic
* whether the container should be restarted

They are kubelet decisions, not control-plane logic.

---

## 6. Probe Types (Condensed)

### Liveness

* Failure causes restart
* Used for hung or dead processes

### Readiness

* Failure stops traffic
* Does not restart container
* Dependency-aware

### Startup

* Delays liveness checks
* Used for slow-starting processes

---

## 7. kube-apiserver Health Endpoints

### `/livez`

* Process is running
* No dependency checks

### `/readyz`

* Safe to serve traffic
* Checks etcd and internal state

### `/healthz`

* Legacy combined endpoint

---

## 8. Probe Execution Model

* Probes are executed locally by kubelet
* kubectl is not involved
* API server is not required

---

## 9. Debugging Order When API Server Is Down

```
journalctl -u kubelet
crictl ps
crictl logs
/var/log/pods
```

---

## 10. Core Control Plane Rule

If the API server is alive but not ready, assume etcd is the cause until proven otherwise.

---
