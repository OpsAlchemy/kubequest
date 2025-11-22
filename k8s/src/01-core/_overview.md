# Table of contents

1. Control plane and node quick map
2. Golden triage flow
3. API server
4. etcd CLI essentials
5. Controller-manager and Scheduler
6. Kubelet deep checks
7. Container runtime and crictl
8. CNI and kube-proxy
9. PKI and kubeadm certs
10. kubectl authentication and authz
11. Logging layout
12. Linux internals that matter
13. Networking deep checks
14. systemctl must-knows
15. Common failure patterns and first commands
16. Quick toolbox
17. Appendix: ports and paths cheat sheet

18. Kuberentes component configuration and options to pass
---

# 1) Control plane and node quick map

* Static pod manifests: `/etc/kubernetes/manifests/*.yaml` (apiserver, controller-manager, scheduler, sometimes etcd)
* Kubelet service: `systemctl status kubelet`, config at `/var/lib/kubelet/config.yaml`
* Runtime sockets: containerd `unix:///run/containerd/containerd.sock`, CRI-O `unix:///var/run/crio/crio.sock`
* CNI bins and config: `/opt/cni/bin`, `/etc/cni/net.d`
* Data dirs: `/var/lib/kubelet`, `/var/lib/containerd` or `/var/lib/crio`, `/var/lib/etcd`, `/var/lib/cni`

# 2) Golden triage flow

1. `kubectl get nodes -o wide` and `kubectl get pods -n kube-system`
2. If control plane pods missing, check kubelet
   `journalctl -u kubelet -n 200 --no-pager`
3. If kubelet OK, inspect static pod files
   `ls -l /etc/kubernetes/manifests` then `crictl ps -a`, `crictl logs <cid>`
4. If API unreachable on master, test local
   `curl -k https://127.0.0.1:6443/healthz` then check `/etc/kubernetes/manifests/kube-apiserver.yaml`
5. If pods cannot start, check CNI and runtime
   `ls /etc/cni/net.d`, `crictl info`, `journalctl -u containerd -n 200`
6. If Services or DNS broken, verify kube-proxy mode and CoreDNS
   `kubectl -n kube-system logs ds/kube-proxy`, `kubectl -n kube-system logs deploy/coredns`

# 3) API server

* Health:
  `curl -k https://127.0.0.1:6443/readyz?verbose`
  `curl -k https://127.0.0.1:6443/livez?verbose`
* Logs on kubeadm installs are container logs
  `kubectl -n kube-system logs pod/kube-apiserver-$(hostname)` or `crictl logs <apiserver-cid>`
* Common breakages

  * Cert SAN mismatch or expiry:
    `openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -text | grep -A2 'DNS:'`
  * Wrong Service CIDR or flags. Compare with kube-proxy config and cluster DNS IP.
  * Etcd connection failure. Verify endpoints and client certs in the apiserver manifest.
* Audit quick check
  If audit enabled, `--audit-log-path` points to the file, often `/var/log/kubernetes/audit.log`.

# 4) etcd CLI essentials

* Use v3 and supply creds:

  ```
  export ETCDCTL_API=3
  etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key endpoint health
  ```
* Members and alarms: `etcdctl member list`, `etcdctl alarm list`
* Snapshot and restore:
  `etcdctl snapshot save /root/snap.db`
  Restore to a new data dir, update the etcd static pod manifest to point to it.
* Space pressure hint: `etcdctl defrag --cluster`

# 5) Controller-manager and Scheduler

* Static pods under `/etc/kubernetes/manifests`, logs via `kubectl -n kube-system logs <pod>`
* Check leader election events:
  `kubectl get events -n kube-system --sort-by=.lastTimestamp | grep -E 'leader|election'`
* Common breakages

  * Bind address set to loopback. Confirm `--bind-address` and `--secure-port`.
  * Kubeconfig paths. Verify `--kubeconfig` flags point under `/etc/kubernetes/`.

# 6) Kubelet deep checks

* Service and drop-ins:
  `systemctl status kubelet`
  `systemctl cat kubelet`
  `cat /etc/systemd/system/kubelet.service.d/10-kubeadm.conf`
* Config and certs:
  `cat /var/lib/kubelet/config.yaml`
  `ls /var/lib/kubelet/pki`
  `ls /etc/kubernetes/kubelet.conf`
* Frequent errors

  * `cni config uninitialized`: ensure files in `/etc/cni/net.d`, restart kubelet.
  * Image pulls fail: `crictl pull <image>`, verify node `/etc/resolv.conf`.
  * Node NotReady: `kubectl describe node <node>`, `journalctl -u kubelet`, check disk `df -h`, OOM `dmesg | grep -i oom`.
  * Certificate rotation: `kubelet.conf` client certs under `/var/lib/kubelet/pki`. Renew with `kubeadm` if needed.

# 7) Container runtime and crictl

* Configure endpoints:

  ```
  crictl config \
    --set runtime-endpoint=unix:///run/containerd/containerd.sock \
    --set image-endpoint=unix:///run/containerd/containerd.sock
  ```
* Must know: `crictl info`, `crictl pods`, `crictl ps -a`, `crictl images`, `crictl logs <cid>`, `crictl inspect <cid>`, `crictl exec -it <cid> sh`
* Get container PID and inspect netns:

  ```
  PID=$(crictl inspect <cid> | sed -n 's/.*"pid": \([0-9]\+\).*/\1/p' | head -1)
  nsenter -t $PID -n ip a
  ```

# 8) CNI and kube-proxy

* CNI check: `ls -l /etc/cni/net.d`, `ls -l /opt/cni/bin`
* Routes and bridges: `ip link`, `ip addr`, `ip route`, `bridge link`, `bridge fdb show`
* kube-proxy mode:
  `kubectl -n kube-system logs ds/kube-proxy | grep -i mode`
  IPVS: `ipvsadm -Ln`
  IPTables: `iptables -t nat -S KUBE-SVC* | head`
* Node sysctls that bite:

  ```
  sysctl net.ipv4.ip_forward
  sysctl net.bridge.bridge-nf-call-iptables
  sysctl net.ipv4.conf.all.rp_filter
  ```

# 9) PKI and kubeadm certs

* List and check expiry: `ls /etc/kubernetes/pki`, `kubeadm certs check-expiration`
* Renew on kubeadm clusters: `kubeadm certs renew all`, then `systemctl restart kubelet`
* Fast SAN or issuer check:
  `openssl x509 -in <crt> -noout -text | grep -A1 'Subject Alternative Name'`

# 10) kubectl authentication and authz

* Current context: `kubectl config view --minify`, `kubectl config get-contexts`
* Test access:
  `kubectl auth can-i <verb> <resource> -n <ns>`
  `kubectl auth can-i '*' '*' --all-namespaces --as <user>`
* Show decision path: `kubectl get <resource> <name> -v=6`
* Webhooks breaking creates:
  `kubectl get validatingwebhookconfigurations,mutatingwebhookconfigurations`

# 11) Logging layout

* Journals: `journalctl -u kubelet`, `journalctl -u containerd` or `-u crio`, kernel `journalctl -k`
* Container logs on node:
  `/var/log/containers` symlinks to `/var/log/pods/<ns>_<pod>_<uid>/<container>/*.log`
* Cluster events: `kubectl get events -A --sort-by=.lastTimestamp`
* Journald space: `journalctl --disk-usage`

# 12) Linux internals that matter

* Processes and parents:
  `ps -eo pid,ppid,cmd --forest | less`, `pstree -ap | grep -E 'kube|containerd|crio'`
* Per process inspection:
  `ls -l /proc/<pid>/fd`, `cat /proc/<pid>/status`, `nsenter -t <pid> -n ip a`
* cgroups v2:
  `/sys/fs/cgroup` then `cat <path>/memory.current`, `cat <path>/cpu.max`
* Filesystem pressure:
  `df -h`, `df -i`, `du -xhd1 /var/lib/containerd/io.overlayfs 2>/dev/null`
* Time sync and skew:
  `timedatectl`, `chronyc sources` or `systemctl status systemd-timesyncd`
* SELinux and AppArmor quick checks:
  `getenforce` on RHEL family, `aa-status` on Ubuntu
* iptables vs nftables:
  `iptables -V`, `update-alternatives --config iptables` on Debian family

# 13) Networking deep checks

* Conntrack health:
  `conntrack -S` and `conntrack -L | wc -l`
  Sysctls: `sysctl net.netfilter.nf_conntrack_max`, current usage under `/proc/sys/net/netfilter/`
* MTU issues:
  `ip link`, `ping -M do -s 8972 <podIP>` to test PMTU with VXLAN
  Ensure CNI MTU matches network
* DNS inside pods:
  `kubectl exec -it <pod> -- cat /etc/resolv.conf` and compare with node
* Open ports snapshot:
  `ss -lntup | grep -E '6443|2379|10250|10257|10259'`

# 14) systemctl must-knows

* `systemctl status NAME`
* `systemctl cat NAME`
* `systemctl daemon-reload`
* `systemctl restart NAME`
* `systemctl enable NAME`
* `systemctl mask NAME`, `systemctl unmask NAME`

# 15) Common failure patterns and first commands

* API down on control plane:
  `crictl ps | grep apiserver || cat /etc/kubernetes/manifests/kube-apiserver.yaml`
  then `crictl logs <apiserver-cid>` and review cert flags
* Node NotReady after CNI install:
  `journalctl -u kubelet -n 200 | grep -i cni`
  `ls /etc/cni/net.d`, confirm cluster CIDRs in plugin config
* Pod stuck in ContainerCreating:
  `kubectl describe pod <p>` for CNI or mount errors
  On node: `crictl inspectp -o json <podid>` and check sandbox status
* Services not routing:
  `kubectl -n kube-system logs ds/kube-proxy`, check IPVS tables or KUBE-SVC chains
* DNS fails in pods:
  `kubectl -n kube-system logs deploy/coredns`
  `kubectl exec -it <pod> -- cat /etc/resolv.conf`
* Throttling or 429s:
  `kubectl get flowcontrol` to inspect APF objects

# 16) Quick toolbox

* One-off DNS pod:
  `kubectl run dns --rm -it --image=registry.k8s.io/e2e-test-images/jessie-dnsutils:1.3 -- sh`
* Ephemeral debug into a running pod:
  `kubectl debug <pod> -it --image=busybox:1.36 --target=<container>`
* Node network ns of a container:
  `nsenter -t $(crictl inspect <cid> | sed -n 's/.*"pid": \([0-9]\+\).*/\1/p' | head -1) -n ip a`

# 17) Appendix: ports and paths cheat sheet

* Ports: API 6443, etcd 2379 to 2380, kubelet 10250, controller-manager 10257, scheduler 10259, CoreDNS 53 TCP and UDP, NodePort 30000 to 32767
* Key paths:
  `/etc/kubernetes/manifests`, `/etc/kubernetes/pki`, `/etc/kubernetes/*.conf`, `/var/lib/kubelet`, `/var/lib/containerd` or `/var/lib/crio`, `/var/lib/etcd`, `/etc/cni/net.d`, `/opt/cni/bin`, `/var/log/containers`, `/var/log/pods`
