root@gatewayapi-control-plane:/etc/kubernetes/pki# ls
apiserver-etcd-client.crt  apiserver-kubelet-client.crt  apiserver.crt  ca.crt  etcd                front-proxy-ca.key      front-proxy-client.key  sa.pub
apiserver-etcd-client.key  apiserver-kubelet-client.key  apiserver.key  ca.key  front-proxy-ca.crt  front-proxy-client.crt  sa.key
root@gatewayapi-control-plane:/etc/kubernetes/pki# ls -la
total 72
drwxr-xr-x 3 root root 4096 Jan  1 07:13 .
drwxr-xr-x 1 root root 4096 Jan  1 07:14 ..
-rw-r--r-- 1 root root 1123 Jan  1 07:13 apiserver-etcd-client.crt
-rw------- 1 root root 1679 Jan  1 07:13 apiserver-etcd-client.key
-rw-r--r-- 1 root root 1176 Jan  1 07:13 apiserver-kubelet-client.crt
-rw------- 1 root root 1675 Jan  1 07:13 apiserver-kubelet-client.key
-rw-r--r-- 1 root root 1334 Jan  1 07:13 apiserver.crt
-rw------- 1 root root 1679 Jan  1 07:13 apiserver.key
-rw-r--r-- 1 root root 1107 Jan  1 07:13 ca.crt
-rw------- 1 root root 1675 Jan  1 07:13 ca.key
drwxr-xr-x 2 root root 4096 Jan  1 07:13 etcd
-rw-r--r-- 1 root root 1123 Jan  1 07:13 front-proxy-ca.crt
-rw------- 1 root root 1679 Jan  1 07:13 front-proxy-ca.key
-rw-r--r-- 1 root root 1119 Jan  1 07:13 front-proxy-client.crt
-rw------- 1 root root 1675 Jan  1 07:13 front-proxy-client.key
-rw------- 1 root root 1675 Jan  1 07:13 sa.key
-rw------- 1 root root  451 Jan  1 07:13 sa.pub
root@gatewayapi-control-plane:/etc/kubernetes/pki# ls etcd
ca.crt  ca.key  healthcheck-client.crt  healthcheck-client.key  peer.crt  peer.key  server.crt  server.key
root@gatewayapi-control-plane:/etc/kubernetes/pki# exit
exit

~/.kube                                                                                     