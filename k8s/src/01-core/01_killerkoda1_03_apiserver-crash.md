Concepts Should Have Known:
1. journalctl
2. syslog
3. circtl
4. apiserver-config
5. kubeadm
6. static pod
7. pod logs
8. continaer logs

```sh
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.ori

vim /etc/kubernetes/manifests/kube-apiserver.yaml

watch -n 2 'crictl ps -a | grep kube-apiserver'

kubectl -n kube-system get pods

crictl ps -a | grep kube-apiserver
crictl logs "$(crictl ps -a | awk '/kube-apiserver/ {print $1; exit}')" | tail -n 100

ls -l /var/log/containers | grep kube-apiserver
tail -n 200 /var/log/pods/kube-system_kube-apiserver-$(hostname)_*/kube-apiserver/0.log

journalctl -u kubelet -n 200 --no-pager | grep -i -E 'apiserver|static pod|failed|error'
journalctl -u containerd -n 100 --no-pager

docker ps | grep kube-apiserver
docker logs "$(docker ps -aq --filter name=kube-apiserver | head -n 1)" | tail -n 100

cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml

systemctl restart kubelet

crictl ps | grep kube-apiserver

curl -k https://127.0.0.1:6443/readyz?verbose
kubectl get nodes -o wide

kubectl -n kube-system get pods
crictl inspect "$(crictl ps -a | awk '/kube-apiserver/ {print $1; exit}')" | sed -n 's/.*"exitCode":\s*\([0-9]\+\).*/\1/p'

crictl info | head -n 40
grep -E -- '--etcd|--client-ca-file|--tls-cert-file|--tls-private-key-file|--kubelet-client' /etc/kubernetes/manifests/kube-apiserver.yaml
ls -l /etc/kubernetes/pki
sed -i '/--this-is-very-wrong/d' /etc/kubernetes/manifests/kube-apiserver.yaml
systemctl restart kubelet\

curl -k https://127.0.0.1:6443/livez?verbose
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```


# Scenario

The exercise is to deliberately misconfigure the API server and practice recovering it. You will:

* Edit the static pod manifest for the API server and add an invalid flag `--this-is-very-wrong`.
* Observe that the API server does not come back.
* Find the failure using the correct log locations and CRI tooling.
* Fix the manifest and confirm recovery.

You should be fully comfortable when the API server is down. You must be able to operate from the node using kubelet, CRI, and on-disk logs.

# Primary log and signal locations

* Pod and container logs on disk

  * `/var/log/pods/<ns>_<pod>_<uid>/<container>/0.log`
  * `/var/log/containers/*.log` (symlinks into `/var/log/pods`)
* CRI runtime and container view

  * `crictl ps`, `crictl ps -a`, `crictl logs <container_id>`, `crictl inspect <container_id>`
* Docker environments only

  * `docker ps`, `docker logs <container_id>`
* Kubelet logs

  * `journalctl -u kubelet -n 200 --no-pager` or on some distros `/var/log/syslog` and `journalctl -k`
* Runtime service logs

  * `journalctl -u containerd -n 200` or `journalctl -u crio -n 200`

# What you did in this run

1. Always back up the manifest

```
cp /etc/kubernetes/manifests/kube-apiserver.yaml ~/kube-apiserver.yaml.ori
```

2. Misconfigure the API server

```
vim /etc/kubernetes/manifests/kube-apiserver.yaml
# add:
#   - --this-is-very-wrong
# save and exit
```

3. Watch the static pod restart loop

```
watch crictl ps
# or: watch -n 2 'crictl ps -a | grep kube-apiserver'
```

4. Try a quick API check and see it is not responding

```
kubectl -n kube-system get pod
# likely fails or hangs because apiserver is down
```

5. Drop to node-level triage

* List containers and find the apiserver container ID

  ```
  crictl ps -a | grep kube-apiserver
  # or:
  crictl ps --name kube-apiserver
  ```
* Read the container logs

  ```
  crictl logs <apiserver_container_id> | tail -n 100
  ```

  You should see an error like: unknown flag or “flag provided but not defined”.
* Also confirm on-disk log path

  ```
  cd /var/log/pods/kube-system_kube-apiserver-$(hostname)_*/kube-apiserver
  tail -n 200 0.log
  ```

6. Fix the manifest

* Revert or remove the bad flag

  ```
  cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml
  # optional but safe:
  systemctl restart kubelet
  ```

7. Verify recovery

```
crictl ps | grep kube-apiserver
curl -k https://127.0.0.1:6443/readyz?verbose
kubectl get nodes -o wide
kubectl -n kube-system get pods
```

# Why these steps work

* The API server on kubeadm nodes runs as a static pod. The kubelet watches `/etc/kubernetes/manifests` and restarts containers whenever the manifest changes. Any invalid flag causes the container to exit. The kubelet keeps retrying.
* API server logs are container logs, not systemd unit logs. You will not find `kube-apiserver` under `systemctl`. You must use CRI logs or the on-disk CRI log files under `/var/log/pods` and `/var/log/containers`.
* When the API server is down, `kubectl` calls fail. You must pivot to node tools: kubelet journals, CRI logs, filesystem.
















# Deep dive and extra checks you should do

## A) Pinpoint the exact failure quickly

```
# containers and exit codes
crictl ps -a --name kube-apiserver
crictl inspect <cid> | jq '.info.exitCode,.info.timestop,.status'
crictl logs <cid> | tail -n 50
```

If `jq` is not available, skip that part or use `sed` to grab fields.

Check kubelet for sync errors and manifest parsing issues:

```
journalctl -u kubelet -n 200 --no-pager | grep -i -E 'apiserver|static pod|failed|error'
```

## B) Confirm the file-based log symlink path

```
ls -l /var/log/containers | grep kube-apiserver
# shows a symlink like kube-apiserver-<node>_kube-system_kube-apiserver-*.log -> /var/log/pods/.../kube-apiserver/0.log
```

## C) Validate runtime health while API is down

```
crictl info | head -n 40
journalctl -u containerd -n 100 --no-pager    # or -u crio
```

## D) If the manifest became invalid YAML

Kubelet logs will show “failed to sync pod” or YAML parse errors. The container may never spawn, so `crictl ps -a` will not show a new container ID. That is your clue to focus on kubelet journal and the manifest file syntax.

## E) If you suspect certificate or etcd flags

When the API server starts but crashes after initialization:

```
# check paths in the manifest
grep -E -- '--etcd|--client-ca-file|--tls-cert-file|--tls-private-key-file|--kubelet-client' /etc/kubernetes/manifests/kube-apiserver.yaml

# verify files exist
ls -l /etc/kubernetes/pki
```

etcd connectivity and cert mismatches also show up in the apiserver container logs.

## F) Common misconfig variants to practice

* Wrong flag name or spelling. Signature: “flag provided but not defined”.
* Wrong file path under `/etc/kubernetes/pki`. Signature: “no such file or directory”, or “failed to load key pair”.
* etcd endpoint mismatch or wrong certs. Signature: “connection refused”, “authentication handshake failed”.
* Service CIDR mismatch with kube-proxy. Signature: kube-proxy warnings and service resolution failures after apiserver comes up.
* Admission or webhook dead-ends. Signature: API starts, but object creation fails with timeouts. You can still check `kubectl get validatingwebhookconfigurations`.

# Strong recovery pattern

1. If you made one edit, revert first

```
cp ~/kube-apiserver.yaml.ori /etc/kubernetes/manifests/kube-apiserver.yaml
systemctl restart kubelet
```

2. If backup is missing, surgically remove the bad line

```
sed -i '/--this-is-very-wrong/d' /etc/kubernetes/manifests/kube-apiserver.yaml
systemctl restart kubelet
```

3. Confirm liveness and API function

```
curl -k https://127.0.0.1:6443/livez?verbose
curl -k https://127.0.0.1:6443/readyz?verbose
kubectl get nodes -o wide
kubectl get events -A --sort-by=.lastTimestamp | tail -n 20
```

# Post-recovery housekeeping

* Check for crashloop debris and old logs

  ```
  crictl ps -a --name kube-apiserver
  ```
* Confirm cert expiration to avoid future surprises

  ```
  kubeadm certs check-expiration
  ```
* Snapshot etcd if this was a production control plane after recovery

  ```
  export ETCDCTL_API=3
  etcdctl --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/server.crt \
    --key=/etc/kubernetes/pki/etcd/server.key snapshot save /root/etcd-snap.db
  ```

# Quick reference checklist

* Edit scope

  * Static pod manifest: `/etc/kubernetes/manifests/kube-apiserver.yaml`
  * Kubelet reloads on file change automatically
* When API is down

  * Use `crictl ps -a`, `crictl logs <cid>`
  * Read `/var/log/pods/.../0.log`
  * Read kubelet journal
* Fix and confirm

  * Revert manifest or remove the bad flag
  * `systemctl restart kubelet` if needed
  * `curl -k https://127.0.0.1:6443/readyz?verbose`
  * `kubectl get nodes`, `kubectl -n kube-system get pods`














systemd
crictl
journalctl
ip
iptable
nmcli
brctl
ip link
cgroup
namespace
process monitoring
storage and stuff
complete van vidoe

modprobe
br_netfilter

bridge