Here’s a clean **notes summary of your kubelet failure scenario** that you can reuse for exam prep or troubleshooting docs:

---

## Scenario: kubelet Crash due to Wrong CA File Path

### Symptoms

* `kubectl` cannot reach the cluster.
* `systemctl status kubelet` shows kubelet repeatedly failing with **exit-code 1**.
* Logs (`journalctl -u kubelet`) contain:

  ```
  "command failed" err="failed to construct kubelet dependencies:
  unable to load client CA file /etc/kubernetes/pki/CA.CERTIFICATE:
  no such file or directory"
  ```

### Root Cause

* In `/var/lib/kubelet/config.yaml` (or kubelet systemd drop-ins), the field:

  ```yaml
  clientCAFile: /etc/kubernetes/pki/CA.CERTIFICATE
  ```

  points to a **non-existent file**.
* Correct path (for kubeadm clusters) should be:

  ```
  /etc/kubernetes/pki/ca.crt
  ```

### Resolution Steps

1. **Check if the CA file exists**:

   ```bash
   ls -l /etc/kubernetes/pki/ca.crt
   ```

2. **Inspect kubelet config**:

   ```bash
   grep -n clientCAFile /var/lib/kubelet/config.yaml
   ```

3. **Fix the wrong path**:

   ```bash
   sudo cp /var/lib/kubelet/config.yaml /var/lib/kubelet/config.yaml.bak.$(date +%s)
   sudo sed -i 's#clientCAFile: .*#clientCAFile: /etc/kubernetes/pki/ca.crt#' /var/lib/kubelet/config.yaml
   ```

4. **Reload and restart services**:

   ```bash
   sudo systemctl daemon-reload
   sudo systemctl restart kubelet
   ```

5. **Verify kubelet is running**:

   ```bash
   sudo systemctl status kubelet --no-pager
   kubectl get nodes
   ```

### Key Takeaways

* Always verify **paths in kubelet config** (`config.yaml` and systemd drop-ins).
* Common kubeadm cluster CA file = `/etc/kubernetes/pki/ca.crt`.
* Many log lines about deprecated flags are warnings; the *real* error is usually further down (look for `err=`).
* Back up config before editing, so you can roll back quickly.

---

👉 Do you want me to also prepare a **compact 1-page “Kubelet Troubleshooting Cheatsheet”** (covering CA cert issues, cgroup mismatch, CRI endpoint, swap) for quick recall during CKA/CKAD practice?
