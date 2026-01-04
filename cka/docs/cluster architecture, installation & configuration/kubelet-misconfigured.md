# Kubelet Misconfigured

### Scenario Overview

`node01` appeared unstable: workloads such as **Calico (canal)**, **CoreDNS**, and **kube-proxy** containers were intermittently running, while the node itself was repeatedly failing to register with the API server. `kubectl` commands from the node failed or returned RBAC errors.

The core issue was a **misconfigured kubelet startup flag** that caused kubelet to crash-loop.

---

## Key Observations

### 1. API Server Connectivity Errors

Kubelet logs showed repeated failures to reach the API server:

```
dial tcp 172.30.1.2:6443: connect: network is unreachable
```

Additionally:

```
can't get ip address of node node01. error: no default routes found
```

This occurred while kubelet was partially starting and failing repeatedly.

---

### 2. Why Calico / CoreDNS Containers Were Still Running

* These components are **static pods** or **previously scheduled pods**.
* The kubelet had been running earlier and successfully:

  * Registered the node
  * Pulled images
  * Created pod sandboxes
* When kubelet later entered a crash loop:

  * **Already-running containers were not immediately terminated**
  * Containerd continued to keep them alive
* However:

  * Pod lifecycle management
  * ConfigMap sync
  * ServiceAccount token projection
    all failed because kubelet could no longer authenticate properly.

This explains the confusing state where containers existed but the node was effectively broken.

---

### 3. Symptoms Pointing to Kubelet Misconfiguration

From `systemctl status kubelet` and `journalctl`:

```
failed to parse kubelet flag: unknown flag: --improve-speed
```

This error caused kubelet to:

* Exit immediately
* Be restarted by systemd
* Enter a continuous crash loop

---

## Investigation Steps

### Check kubelet service status

```
systemctl status kubelet
```

### Inspect kubelet logs

```
journalctl -u kubelet
# or
grep kubelet /var/log/syslog
```

### Inspect kubelet startup configuration

```
systemctl cat kubelet
```

Key discovery: kubelet arguments are assembled from multiple sources.

---

## Root Cause

An **invalid kubelet flag** was injected via kubeadm-managed configuration:

```
--improve-speed
```

This flag is **not a valid kubelet option** and caused kubelet startup to fail.

The flag was present in:

```
/var/lib/kubelet/kubeadm-flags.env
```

Contents before fix:

```
KUBELET_KUBEADM_ARGS="--pod-infra-container-image=registry.k8s.io/pause:3.10.1 --improve-speed"
```

Likely scenario: someone attempted to “optimize” kubelet startup and unintentionally broke the node.

---

## Resolution

### 1. Edit kubeadm-managed kubelet flags

```
vi /var/lib/kubelet/kubeadm-flags.env
```

Remove the invalid flag:

```
KUBELET_KUBEADM_ARGS="--pod-infra-container-image=registry.k8s.io/pause:3.10.1"
```

### 2. Restart kubelet

```
systemctl restart kubelet
```

### 3. Verify kubelet health

```
systemctl status kubelet
```

Kubelet should now:

* Start successfully
* Re-register the node
* Resume normal pod and volume management

---

## Notes on kubectl Errors During Debugging

* Running `kubectl` without a valid admin kubeconfig defaults to:

  ```
  http://localhost:8080
  ```

  which explains:

  ```
  connection refused
  ```

* Using `kubelet.conf` as `KUBECONFIG` results in **expected RBAC restrictions**:

  * Node identities can only read:

    * Their own Node object
    * Pods scheduled to themselves

This behavior is correct and not an error.

---

## Key Takeaways

* Kubelet is extremely sensitive to invalid flags.
* kubeadm-managed flags live in:

  ```
  /var/lib/kubelet/kubeadm-flags.env
  ```
* Containers can continue running even when kubelet is crashing.
* Always inspect `systemctl cat kubelet` to understand **effective kubelet arguments**.
* Do not manually “optimize” kubelet flags without validating against official documentation.

---
