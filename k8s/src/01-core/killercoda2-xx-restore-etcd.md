```sh
#!/usr/bin/env bash
set -euo pipefail

# Config
BACKUP_PATH="/opt/cluster_backup.db"
RESTORE_DIR="/root/default.etcd"
RESTORE_LOG="/root/restore.txt"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
CERT_DIR="/etc/kubernetes/pki/etcd"
ENDPOINT="https://127.0.0.1:2379"

ensure_root() {
  if [[ "${EUID:-$(id -u)}" -ne 0 ]]; then
    echo "Run as root"
    exit 1
  fi
}

detect_cert_files() {
  # Prefer healthcheck client certs if present, else fall back to server certs
  if [[ -f "${CERT_DIR}/healthcheck-client.crt" && -f "${CERT_DIR}/healthcheck-client.key" ]]; then
    CLIENT_CERT="${CERT_DIR}/healthcheck-client.crt"
    CLIENT_KEY="${CERT_DIR}/healthcheck-client.key"
  else
    CLIENT_CERT="${CERT_DIR}/server.crt"
    CLIENT_KEY="${CERT_DIR}/server.key"
  fi
  CA_CERT="${CERT_DIR}/ca.crt"
  for f in "$CA_CERT" "$CLIENT_CERT" "$CLIENT_KEY"; do
    [[ -f "$f" ]] || { echo "Missing cert/key: $f"; exit 1; }
  done
}

backup_etcd() {
  echo "Taking etcd snapshot to ${BACKUP_PATH}"
  ETCDCTL_API=3 etcdctl \
    --endpoints="${ENDPOINT}" \
    --cacert="${CA_CERT}" \
    --cert="${CLIENT_CERT}" \
    --key="${CLIENT_KEY}" \
    snapshot save "${BACKUP_PATH}"
  echo "Snapshot saved at ${BACKUP_PATH}"
  ETCDCTL_API=3 etcdctl snapshot status "${BACKUP_PATH}" || true
}

restore_etcd() {
  echo "Restoring snapshot from ${BACKUP_PATH} into ${RESTORE_DIR}"
  rm -rf "${RESTORE_DIR}"
  ETCDCTL_API=3 etcdctl snapshot restore "${BACKUP_PATH}" \
    --data-dir="${RESTORE_DIR}" \
    --name="controlplane" \
    --initial-cluster="controlplane=https://127.0.0.1:2380" \
    --initial-advertise-peer-urls="https://127.0.0.1:2380" \
    --initial-cluster-token="etcd-cluster-1" \
    2>&1 | tee "${RESTORE_LOG}"
  echo "Restore console output saved to ${RESTORE_LOG}"
}

rewire_static_pod() {
  echo "Pointing etcd static pod to ${RESTORE_DIR}"
  if [[ ! -f "${ETCD_MANIFEST}" ]]; then
    echo "Manifest not found at ${ETCD_MANIFEST}"
    exit 1
  fi
  # Replace any existing data-dir path with the restored dir
  sed -i 's|--data-dir=[^[:space:]]*|--data-dir='"${RESTORE_DIR}"'|g' "${ETCD_MANIFEST}"
  # Ensure the hostPath volume points to the restored dir
  sed -i 's|path: /var/lib/etcd|path: '"${RESTORE_DIR}"'|g' "${ETCD_MANIFEST}"
  # Kubelet will auto-reload static pod manifests
  systemctl restart kubelet || true
  sleep 10
}

verify_etcd() {
  echo "Verifying etcd pod and endpoint"
  # Try both container runtimes for local check
  command -v crictl >/dev/null 2>&1 && crictl ps | grep -i etcd || true
  command -v docker >/dev/null 2>&1 && docker ps | grep -i etcd || true
  # If kubectl is available, check pod
  if command -v kubectl >/dev/null 2>&1; then
    kubectl -n kube-system get pods -l component=etcd || true
  fi
  ETCDCTL_API=3 etcdctl \
    --endpoints="${ENDPOINT}" \
    --cacert="${CA_CERT}" \
    --cert="${CLIENT_CERT}" \
    --key="${CLIENT_KEY}" \
    endpoint status --write-out=table
}

main() {
  ensure_root
  detect_cert_files
  backup_etcd
  restore_etcd
  rewire_static_pod
  verify_etcd
  echo "Done"
}

main "$@"

```









controlplane:~$ BACKUP_PATH="/opt/cluster_backup.db"
RESTORE_DIR="/root/default.etcd"
RESTORE_LOG="/root/restore.txt"
ETCD_MANIFEST="/etc/kubernetes/manifests/etcd.yaml"
CERT_DIR="/etc/kubernetes/pki/etcd"
ENDPOINT="https://127.0.0.1:2379"
controlplane:~$ ETCDCTL_API=3 etcdctl \
    --endpoints="${ENDPOINT}" \
    --cacert="${CA_CERT}" \
    --cert="${CLIENT_CERT}" \
    --key="${CLIENT_KEY}" \
    snapshot save "${BACKUP_PATH}"
Error: empty string is passed to --cert option
controlplane:~$ if [[ -f "${CERT_DIR}/healthcheck-client.crt" && -f "${CERT_DIR}/healthcheck-client.key" ]]; then
    CLIENT_CERT="${CERT_DIR}/healthcheck-client.crt"
    CLIENT_KEY="${CERT_DIR}/healthcheck-client.key"
  else
    CLIENT_CERT="${CERT_DIR}/server.crt"
    CLIENT_KEY="${CERT_DIR}/server.key"
  fi
  CA_CERT="${CERT_DIR}/ca.crt"
  for f in "$CA_CERT" "$CLIENT_CERT" "$CLIENT_KEY"; do
    [[ -f "$f" ]] || { echo "Missing cert/key: $f"; exit 1; }
  done
controlplane:~$ echo "Taking etcd snapshot to ${BACKUP_PATH}"
  ETCDCTL_API=3 etcdctl \
    --endpoints="${ENDPOINT}" \
    --cacert="${CA_CERT}" \
    --cert="${CLIENT_CERT}" \
    --key="${CLIENT_KEY}" \
    snapshot save "${BACKUP_PATH}"
  echo "Snapshot saved at ${BACKUP_PATH}"
  ETCDCTL_API=3 etcdctl snapshot status "${BACKUP_PATH}" || true
Taking etcd snapshot to /opt/cluster_backup.db
{"level":"info","ts":1756892698.05626,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/opt/cluster_backup.db.part"}
{"level":"info","ts":1756892698.0642478,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1756892698.0646427,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://127.0.0.1:2379"}
{"level":"info","ts":1756892698.167355,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1756892698.1766994,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://127.0.0.1:2379","size":"4.3 MB","took":"now"}
{"level":"info","ts":1756892698.176963,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/opt/cluster_backup.db"}
Snapshot saved at /opt/cluster_backup.db
Snapshot saved at /opt/cluster_backup.db
Deprecated: Use `etcdutl snapshot status` instead.

df99285e, 3475, 2362, 4.3 MB
controlplane:~$ echo "Restoring snapshot from ${BACKUP_PATH} into ${RESTORE_DIR}"
  rm -rf "${RESTORE_DIR}"
Restoring snapshot from /opt/cluster_backup.db into /root/default.etcd
controlplane:~$ ETCDCTL_API=3 etcdctl snapshot restore "${BACKUP_PATH}" \
    --data-dir="${RESTORE_DIR}" \
    --name="controlplane" \
    --initial-cluster="controlplane=https://127.0.0.1:2380" \
    --initial-advertise-peer-urls="https://127.0.0.1:2380" \
    --initial-cluster-token="etcd-cluster-1" \
    2>&1 | tee "${RESTORE_LOG}"
  echo "Restore console output saved to ${RESTORE_LOG}"
Deprecated: Use `etcdutl snapshot restore` instead.

2025-09-03T09:45:28Z    info    snapshot/v3_snapshot.go:251     restoring snapshot      {"path": "/opt/cluster_backup.db", "wal-dir": "/root/default.etcd/member/wal", "data-dir": "/root/default.etcd", "snap-dir": "/root/default.etcd/member/snap", "stack": "go.etcd.io/etcd/etcdutl/v3/snapshot.(*v3Manager).Restore\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/snapshot/v3_snapshot.go:257\ngo.etcd.io/etcd/etcdutl/v3/etcdutl.SnapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/etcdutl/snapshot_command.go:147\ngo.etcd.io/etcd/etcdctl/v3/ctlv3/command.snapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/command/snapshot_command.go:128\ngithub.com/spf13/cobra.(*Command).execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:856\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:960\ngithub.com/spf13/cobra.(*Command).Execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:897\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.Start\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.MustStart\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/main.go:59\nruntime.main\n\t/home/remote/sbatsche/.gvm/gos/go1.16.3/src/runtime/proc.go:225"}
2025-09-03T09:45:29Z    info    membership/store.go:119 Trimming membership information from the backend...
2025-09-03T09:45:29Z    info    membership/cluster.go:393       added member    {"cluster-id": "7581d6eb2d25405b", "local-member-id": "0", "added-peer-id": "e92d66acd89ecf29", "added-peer-peer-urls": ["https://127.0.0.1:2380"]}
2025-09-03T09:45:29Z    info    snapshot/v3_snapshot.go:272     restored snapshot       {"path": "/opt/cluster_backup.db", "wal-dir": "/root/default.etcd/member/wal", "data-dir": "/root/default.etcd", "snap-dir": "/root/default.etcd/member/snap"}
Restore console output saved to /root/restore.txt
controlplane:~$ sed -i 's|--data-dir=[^[:space:]]*|--data-dir='"${RESTORE_DIR}"'|g' "${ETCD_MANIFEST}"
controlplane:~$ sed -i 's|path: /var/lib/etcd|path: '"${RESTORE_DIR}"'|g' "${ETCD_MANIFEST}"
controlplane:~$   systemctl restart kubelet || true
controlplane:~$ sleep 10
controlplane:~$ ETCDCTL_API=3 etcdctl \
    --endpoints="${ENDPOINT}" \
    --cacert="${CA_CERT}" \
    --cert="${CLIENT_CERT}" \
    --key="${CLIENT_KEY}" \
    endpoint status --write-out=table
{"level":"warn","ts":"2025-09-03T09:46:40.537Z","logger":"etcd-client","caller":"v3/retry_interceptor.go:62","msg":"retrying of unary invoker failed","target":"etcd-endpoints://0xc0002d8a80/#initially=[https://127.0.0.1:2379]","attempt":0,"error":"rpc error: code = DeadlineExceeded desc = latest balancer error: last connection error: connection error: desc = \"transport: Error while dialing dial tcp 127.0.0.1:2379: connect: connection refused\""}
Failed to get the status of endpoint https://127.0.0.1:2379 (context deadline exceeded)
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
| ENDPOINT | ID | VERSION | DB SIZE | IS LEADER | IS LEARNER | RAFT TERM | RAFT INDEX | RAFT APPLIED INDEX | ERRORS |
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
+----------+----+---------+---------+-----------+------------+-----------+------------+--------------------+--------+
controlplane:~$ 


```sh
#!/bin/bash
set -e

export ETCDCTL_API=3

BACKUP="/opt/cluster_backup.db"
RESTORE_DIR="/root/default.etcd"
RESTORE_LOG="/root/restore.txt"
MANIFEST="/etc/kubernetes/manifests/etcd.yaml"

# Certs (fall back to server.crt/server.key if healthcheck-client not there)
CA_CERT="/etc/kubernetes/pki/etcd/ca.crt"
CLIENT_CERT="/etc/kubernetes/pki/etcd/server.crt"
CLIENT_KEY="/etc/kubernetes/pki/etcd/server.key"

# 1. Stop etcd pod by moving manifest
mv $MANIFEST ${MANIFEST}.bak
sleep 8

# 2. Clean old restore dir
rm -rf $RESTORE_DIR

# 3. Restore snapshot with correct IP (replace 172.30.1.2 with your node IP if different)
etcdctl snapshot restore $BACKUP \
  --data-dir=$RESTORE_DIR \
  --name=controlplane \
  --initial-cluster=controlplane=https://172.30.1.2:2380 \
  --initial-advertise-peer-urls=https://172.30.1.2:2380 \
  --initial-cluster-token=etcd-cluster-1 2>&1 | tee $RESTORE_LOG

# 4. Point manifest to new data-dir
sed -i 's|--data-dir=[^[:space:]]*|--data-dir='"$RESTORE_DIR"'|g' ${MANIFEST}.bak
sed -i 's|path: /var/lib/etcd|path: '"$RESTORE_DIR"'|g' ${MANIFEST}.bak

# 5. Bring back manifest so kubelet restarts etcd
mv ${MANIFEST}.bak $MANIFEST
systemctl restart kubelet || true
sleep 12

# 6. Verify pod
kubectl -n kube-system get pods -l component=etcd || true

# 7. Verify etcd endpoint
etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=$CA_CERT --cert=$CLIENT_CERT --key=$CLIENT_KEY \
  endpoint status --write-out=table || true

etcdctl --endpoints=https://172.30.1.2:2379 \
  --cacert=$CA_CERT --cert=$CLIENT_CERT --key=$CLIENT_KEY \
  endpoint status --write-out=table || true

echo "Backup restored, manifest updated, logs in $RESTORE_LOG"

```