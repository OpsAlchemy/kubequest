https://killercoda.com/chadmcrowell/course/cka/kubernetes-backup-etcd



controlplane:~$ export ETCDCTL_API=3
controlplane:~$ etcdctl snapshot save snapshot --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key
{"level":"info","ts":1756815806.3361535,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"snapshot.part"}
{"level":"info","ts":1756815806.347946,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1756815806.3480227,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"127.0.0.1:2379"}
{"level":"info","ts":1756815806.4417922,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1756815806.4794657,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"127.0.0.1:2379","size":"4.3 MB","took":"now"}
{"level":"info","ts":1756815806.4795585,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"snapshot"}
Snapshot saved at snapshot
controlplane:~$ ls
filesystem  snapshot
controlplane:~$ etcdctl snapshot status snapshot --write-out=table
Deprecated: Use `etcdutl snapshot status` instead.

+----------+----------+------------+------------+
|   HASH   | REVISION | TOTAL KEYS | TOTAL SIZE |
+----------+----------+------------+------------+
| d3af6a78 |     2539 |       1423 |     4.3 MB |
+----------+----------+------------+------------+
controlplane:~$ k delete ds kube-proxy -n kube-system
daemonset.apps "kube-proxy" deleted
controlplane:~$ k get ds -A
NAMESPACE     NAME    DESIRED   CURRENT   READY   UP-TO-DATE   AVAILABLE   NODE SELECTOR            AGE
kube-system   canal   1         1         1       1            1           kubernetes.io/os=linux   14d
controlplane:~$ etcdctl snapshot restore snapshot --data-dir /var/lib/etcd-restore
Deprecated: Use `etcdutl snapshot restore` instead.

2025-09-02T12:24:29Z    info    snapshot/v3_snapshot.go:251     restoring snapshot      {"path": "snapshot", "wal-dir": "/var/lib/etcd-restore/member/wal", "data-dir": "/var/lib/etcd-restore", "snap-dir": "/var/lib/etcd-restore/member/snap", "stack": "go.etcd.io/etcd/etcdutl/v3/snapshot.(*v3Manager).Restore\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/snapshot/v3_snapshot.go:257\ngo.etcd.io/etcd/etcdutl/v3/etcdutl.SnapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdutl/etcdutl/snapshot_command.go:147\ngo.etcd.io/etcd/etcdctl/v3/ctlv3/command.snapshotRestoreCommandFunc\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/command/snapshot_command.go:128\ngithub.com/spf13/cobra.(*Command).execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:856\ngithub.com/spf13/cobra.(*Command).ExecuteC\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:960\ngithub.com/spf13/cobra.(*Command).Execute\n\t/home/remote/sbatsche/.gvm/pkgsets/go1.16.3/global/pkg/mod/github.com/spf13/cobra@v1.1.3/command.go:897\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.Start\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:107\ngo.etcd.io/etcd/etcdctl/v3/ctlv3.MustStart\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/ctlv3/ctl.go:111\nmain.main\n\t/tmp/etcd-release-3.5.0/etcd/release/etcd/etcdctl/main.go:59\nruntime.main\n\t/home/remote/sbatsche/.gvm/gos/go1.16.3/src/runtime/proc.go:225"}
2025-09-02T12:24:29Z    info    membership/store.go:119 Trimming membership information from the backend...
2025-09-02T12:24:29Z    info    membership/cluster.go:393       added member    {"cluster-id": "cdf818194e3a8c32", "local-member-id": "0", "added-peer-id": "8e9e05c52164694d", "added-peer-peer-urls": ["http://localhost:2380"]}
2025-09-02T12:24:30Z    info    snapshot/v3_snapshot.go:272     restored snapshot       {"path": "snapshot", "wal-dir": "/var/lib/etcd-restore/member/wal", "data-dir": "/var/lib/etcd-restore", "snap-dir": "/var/lib/etcd-restore/member/snap"}
controlplane:~$ /etc/kubernetes/manifests/etcd.yaml
bash: /etc/kubernetes/manifests/etcd.yaml: Permission denied
controlplane:~$ vi /etc/kubernetes/manifests/etcd.yaml
controlplane:~$ k get ds -A

