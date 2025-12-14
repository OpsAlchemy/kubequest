# kube-apiserver Crash (Static Pod)

You debugged this **correctly and in the right order**. Nothing embarrassing here.
These are the **exact failure modes kubeadm clusters are designed to test**, both in real life and in exams.

This document merges:

* the **Apiserver Crash scenario**
* the **correct IPs, ports, and flags**
* the **real debugging chain you followed**
  into one **compact, exam-safe reference**.

---

## Scenario

**Problem**
The kube-apiserver is not coming up.
The static pod manifest is misconfigured in **three places**.
Fix them to recover the control plane.

---

## Core kubeadm facts (must know)

* Control plane components are **static pods**
* Static pod manifests live in:

  ```
  /etc/kubernetes/manifests/
  ```
* kubelet **continuously watches** this directory
* Any valid change → kubelet recreates the container automatically

If changes don’t apply cleanly:

* Move the manifest out of the directory
* Wait for the container to disappear (`crictl ps`)
* Move it back

Restarting kubelet is **usually not required**, but acceptable if kubelet is stuck.

---

## Log locations (order matters)

When the API server is down, **kubectl does not work**.

Use this order:

1. **kubelet logs**

   ```
   journalctl -u kubelet
   /var/log/syslog
   ```

2. **Static pod logs**

   ```
   /var/log/pods/
   /var/log/containers/
   ```

3. **Container runtime**

   ```
   crictl ps
   crictl ps -a
   crictl logs <container-id>
   ```

(Docker commands only if Docker runtime is used.)

---

## Canonical IPs and Ports (single-node control plane)

### kube-apiserver

* **IP**: Node internal IP (example: `172.30.1.2`)
* **Port**: `6443`

Always:

```
https://<control-plane-node-ip>:6443
```

If `:6443` is refused:

* apiserver is not listening
* or it crashed immediately after start

---

### etcd (stacked topology)

* **IP**: `127.0.0.1`
* **Port**: `2379`

Always:

```
https://127.0.0.1:2379
```

If apiserver points anywhere else → **CrashLoopBackOff**

---

## Absolute minimum kube-apiserver flags (do not memorize more)

```yaml
- --advertise-address=<node-ip>
- --secure-port=6443
- --etcd-servers=https://127.0.0.1:2379
```

If any of these are wrong, you will see **exactly** the failures in this scenario.

---

## Root Cause Analysis (the three misconfigurations)

### Issue 1 — kubelet cannot create the Pod

**Symptoms**

* `crictl ps` shows no kube-apiserver container
* apiserver never starts even once

**Where to look**

```
journalctl -u kubelet
or
cat /var/log/syslog | grep kube-apiserver
```

**Error**

* Invalid YAML in `kube-apiserver.yaml`
* Syntax error in `metadata`

**Fix**

* Correct YAML in:

  ```
  /etc/kubernetes/manifests/kube-apiserver.yaml
  ```

**Result**

* kubelet can now create the container

---

### Issue 2 — invalid kube-apiserver flag

**Symptoms**

* Container is created
* Immediately exits
* `crictl ps -a` shows `Exited`

**Where to look**

```
/var/log/pods/kube-system_kube-apiserver-*/
crictl logs <container-id>
```

**Error**

```
unknown flag: --authorization-modus
```

**Fix**
Incorrect:

```
--authorization-modus
```

Correct:

```
--authorization-modes
```

**Result**

* apiserver binary starts correctly

---

### Issue 3 — wrong etcd endpoint

**Symptoms**

* apiserver starts
* then restarts repeatedly
* kubelet logs show connection refused
* kubectl still cannot connect

**Error**

```
dial tcp 127.0.0.1:23000: connect: connection refused
```

**Root cause**

* apiserver pointing to wrong etcd port

**How to verify**
Check:

```
/etc/kubernetes/manifests/etcd.yaml
```

etcd listens on:

```
127.0.0.1:2379
```

**Fix**

```
--etcd-servers=https://127.0.0.1:2379
```

**Result**

* apiserver stays up
* API becomes reachable

---

## Final validation

```
crictl ps | grep kube-apiserver
```

State must be `Running`

```
kubectl get nodes
kubectl get pods -A
```

Cluster responds normally

---

## TLS paths (do not invent these)

### API server

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

If these exist, **do not touch them**.

---

## Failure chain (mental model)

### Step-by-step interpretation

1. `crictl ps` empty
   → YAML or kubelet-level failure

2. kubelet error: YAML parse
   → Fix manifest

3. Container exits immediately
   → Invalid flag

4. `connection refused` to `:6443`
   → apiserver down

5. `connection refused` to `:2379`
   → etcd misconfigured

---

## Command ladder (never skip)

```
crictl ps
↓
journalctl -u kubelet
↓
crictl logs kube-apiserver
↓
crictl logs etcd
```

---

## One-sentence rule (remember forever)

> If kube-apiserver is down, **etcd is guilty until proven innocent**.

---

## Exam-safe port table

| Component       | IP        | Port  |
| --------------- | --------- | ----- |
| kube-apiserver  | Node IP   | 6443  |
| etcd            | 127.0.0.1 | 2379  |
| kubelet healthz | 127.0.0.1 | 10248 |

---
