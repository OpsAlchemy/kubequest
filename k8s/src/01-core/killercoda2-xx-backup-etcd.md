controlplane:~$ cat backup.txt 
Snapshot saved at /opt/cluster_backup.db
controlplane:~$ ^C
controlplane:~$ ^[[200~ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
>   --cacert=/etc/kubernetes/pki/etcd/ca.crt \
>   --cert=/etc/kubernetes/pki/etcd/server.crt \
>   --key=/etc/kubernetes/pki/etcd/server.key \
>   snapshot save /opt/cluster_backup.db 2>&1 | tee backup.txt
ETCDCTL_API=3: command not found
controlplane:~$ ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/cluster_backup.db 2>&1 | tee backup.txt
{"level":"info","ts":1756893586.1124675,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/opt/cluster_backup.db.part"}
{"level":"info","ts":1756893586.1177766,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1756893586.1178002,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://127.0.0.1:2379"}
{"level":"info","ts":1756893586.1988826,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1756893586.2222786,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://127.0.0.1:2379","size":"4.3 MB","took":"now"}
{"level":"info","ts":1756893586.222863,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/opt/cluster_backup.db"}
Snapshot saved at /opt/cluster_backup.db
controlplane:~$ ls
backup.txt  filesystem
controlplane:~$ cat backup.txt 
{"level":"info","ts":1756893586.1124675,"caller":"snapshot/v3_snapshot.go:68","msg":"created temporary db file","path":"/opt/cluster_backup.db.part"}
{"level":"info","ts":1756893586.1177766,"logger":"client","caller":"v3/maintenance.go:211","msg":"opened snapshot stream; downloading"}
{"level":"info","ts":1756893586.1178002,"caller":"snapshot/v3_snapshot.go:76","msg":"fetching snapshot","endpoint":"https://127.0.0.1:2379"}
{"level":"info","ts":1756893586.1988826,"logger":"client","caller":"v3/maintenance.go:219","msg":"completed snapshot read; closing"}
{"level":"info","ts":1756893586.2222786,"caller":"snapshot/v3_snapshot.go:91","msg":"fetched snapshot","endpoint":"https://127.0.0.1:2379","size":"4.3 MB","took":"now"}
{"level":"info","ts":1756893586.222863,"caller":"snapshot/v3_snapshot.go:100","msg":"saved","path":"/opt/cluster_backup.db"}
Snapshot saved at /opt/cluster_backup.db
controlplane:~$ 




ETCDCTL_API=3 etcdctl --endpoints=https://127.0.0.1:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  snapshot save /opt/cluster_backup.db 2>&1 | tee backup.txt
