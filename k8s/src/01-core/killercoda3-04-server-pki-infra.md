controlplane:~$ cat /etc/kuberentes/pki
cat: /etc/kuberentes/pki: No such file or directory
controlplane:~$ cd /etc/kubernetes/pki
controlplane:/etc/kubernetes/pki$ ls
apiserver-etcd-client.crt     apiserver-kubelet-client.key  ca.crt  front-proxy-ca.crt      front-proxy-client.key
apiserver-etcd-client.key     apiserver.crt                 ca.key  front-proxy-ca.key      sa.key
apiserver-kubelet-client.crt  apiserver.key                 etcd    front-proxy-client.crt  sa.pub
controlplane:/etc/kubernetes/pki$ 