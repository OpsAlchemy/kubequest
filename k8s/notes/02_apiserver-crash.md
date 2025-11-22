controlplane:/etc/kubernetes/manifests$ kubectl get pods -A\
> ^C
controlplane:/etc/kubernetes/manifests$ kubectl get pods -A 
The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?
controlplane:/etc/kubernetes/manifests$ cat /var/log/pods
cat: /var/log/pods: Is a directory
controlplane:/etc/kubernetes/manifests$ cd /var/log
controlplane:/var/log$ ls
README            apt                    containers    dmesg.1.gz      killercoda  syslog
Xorg.0.log        auth.log               cups          dmesg.2.gz      landscape   sysstat
alternatives.log  btmp                   cups-browsed  dpkg.log        lastlog     unattended-upgrades
apport.log        calico                 dist-upgrade  fontconfig.log  lightdm     wtmp
apport.log.1      cloud-init-output.log  dmesg         journal         pods
apport.log.2.gz   cloud-init.log         dmesg.0       kern.log        private
controlplane:/var/log$ cd pods
controlplane:/var/log/pods$ ls
kube-system_calico-kube-controllers-fdf5f5495-8jbqm_7ac5e0c1-e88f-4814-aeaa-db71d4a41248
kube-system_canal-rtfc5_c1f261ea-9cbf-43ca-885e-7c7811b8d5f6
kube-system_coredns-6ff97d97f9-2rxsf_2001369b-a888-4bdd-8555-c8d026262009
kube-system_coredns-6ff97d97f9-85m5c_7eef878c-2943-4bf3-be3c-a442c8c1eedb
kube-system_etcd-controlplane_0a20c757572c0a1fc40cf46300cfcf97
kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4
kube-system_kube-controller-manager-controlplane_bc2d002eef4f6ab030edec4bdf370f16
kube-system_kube-proxy-7kdz8_e7ad3206-b5e2-43c4-8f7a-6380b39e9208
kube-system_kube-scheduler-controlplane_3bfb9bf8f1e4a4dbe1a89a770e151a87
local-path-storage_local-path-provisioner-5c94487ccb-gmwjg_90bd1749-4aa8-4158-bc70-7f85e1b31626
controlplane:/var/log/pods$ cat kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/
cat: kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/: Is a directory
controlplane:/var/log/pods$ cd kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4$ ls
kube-apiserver
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4$ cd kube-apiserver/
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/kube-apiserver$ ls
4.log
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/kube-apiserver$ cat 4.log
2025-08-23T02:49:02.855887445Z stderr F Error: unknown flag: --this-is-very-wrong
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/kube-apiserver$ cat /var/log/containers
cat: /var/log/containers: Is a directory
controlplane:/var/log/pods/kube-system_kube-apiserver-controlplane_49bacb5cae5c51ba8b4dc938cec127e4/kube-apiserver$ cd /var/log/containers
controlplane:/var/log/containers$ ls
calico-kube-controllers-fdf5f5495-8jbqm_kube-system_calico-kube-controllers-153a4c2e0831e54ee969e747ce7e63874a0c2851037cdd657c09c83fdbc2b2f9.log
calico-kube-controllers-fdf5f5495-8jbqm_kube-system_calico-kube-controllers-71c23b9b086dc5a5a9d420a263671d5b0398e2dba14f97cec6c04fc4059ee476.log
canal-rtfc5_kube-system_calico-node-3268c994911f6f0dee943bc20ae3144c845a935552860a26117113f766f43a6b.log
canal-rtfc5_kube-system_calico-node-acb3df6824931ff8bec6741d13d6fe0813d0b58e80d258d0f4cd510938a8830a.log
canal-rtfc5_kube-system_install-cni-f75d43a9da7b3b70a7344153f01d2acdcb73e068283c2beafdf75427fe2e3e42.log
canal-rtfc5_kube-system_kube-flannel-9959fa9e11566c57654d19aa5fc4c9c64112714ba2c17eccadbb2d977a17b6bd.log
canal-rtfc5_kube-system_kube-flannel-d086b88a2535aca10c52918b1280854ce4ae06a162218160c8a25a57333643a4.log
canal-rtfc5_kube-system_mount-bpffs-ef49bbf92b4bea2c60abe7c19c37a972fb728735724b3afa4e25bdb9c17dff8c.log
coredns-6ff97d97f9-2rxsf_kube-system_coredns-d95ca82081ac05e596372c70038b9b26ebfe2cc35f23fe39bc5fedb89c8c556f.log
coredns-6ff97d97f9-2rxsf_kube-system_coredns-fc8002a7d28c01d4a476af330bbf73bc8ffbe6f0bce06b0868742f162f4dead3.log
coredns-6ff97d97f9-85m5c_kube-system_coredns-167b0946f571b21fe66d072cb245861c0fa797851d7d57bb4befe9c7d600ebf5.log
coredns-6ff97d97f9-85m5c_kube-system_coredns-824511e16580b582fe03ffd795200474babec06be472cc3f77e9c8a3b4cd58a1.log
etcd-controlplane_kube-system_etcd-50481e2aa1688d9258ce8567f667b3b5c9eec3b7b0bee8e9db3e6c398cdc75fb.log
etcd-controlplane_kube-system_etcd-ad415e1704cf13d5407a7944cd621b76e18e5e8de4b9e31e8448da1c7c72a433.log
kube-apiserver-controlplane_kube-system_kube-apiserver-1bb8f023e594df4bfc17c1a4486e5014925880e6eee1b0a2554e99c824c05adf.log
kube-controller-manager-controlplane_kube-system_kube-controller-manager-914c342d2412cb057b96b56bda09ecda070edeff2e324efa0b75adadd49ed376.log
kube-controller-manager-controlplane_kube-system_kube-controller-manager-dfb2955cbb30681ab22de87cb4d7cf7686ad64d4f3a27f65069adf7236d4a6d5.log
kube-proxy-7kdz8_kube-system_kube-proxy-4c881ddd2fd7df9becf4d4b6eee7b77b3066410a7e3b0f7e8c29a7f52780562e.log
kube-proxy-7kdz8_kube-system_kube-proxy-aa945d6c206f8b28dc1094c17ce54bf4797c07cb5c1eb756762d32b74504f6b4.log
kube-scheduler-controlplane_kube-system_kube-scheduler-0a888fc47a665facb8e2571142d1982e830eeef9bc43f82d460b37d90fa0a3d4.log
kube-scheduler-controlplane_kube-system_kube-scheduler-43dc491013e5f1e5c052e16d92adbdb7ff7ffd808c1b62a4ac8b9b5a6273fc32.log
local-path-provisioner-5c94487ccb-gmwjg_local-path-storage_local-path-provisioner-bc5709afb8c2a6ff217483862211a16d559e48ac20e6303d6a18c51ef6560ab4.log
local-path-provisioner-5c94487ccb-gmwjg_local-path-storage_local-path-provisioner-bf0ff3d39592c7b05f05a8e2f6215569c20b5ebfa56a26627b0a1980198575b4.log
controlplane:/var/log/containers$ cd kube-apiserver-controlplane_kube-system_kube-apiserver-1bb8f023e594df4bfc17c1a4486e5014925880e6eee1b0a2554e99c824c05adf.log
bash: cd: kube-apiserver-controlplane_kube-system_kube-apiserver-1bb8f023e594df4bfc17c1a4486e5014925880e6eee1b0a2554e99c824c05adf.log: Not a directory
controlplane:/var/log/containers$ cat kube-apiserver-controlplane_kube-system_kube-apiserver-1bb8f023e594df4bfc17c1a4486e5014925880e6eee1b0a2554e99c824c05adf.log
2025-08-23T02:50:31.847661303Z stderr F Error: unknown flag: --this-is-very-wrong
controlplane:/var/log/containers$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
0a888fc47a665       cfed1ff748928       4 minutes ago       Running             kube-scheduler            2                   c811356bfbc40       kube-scheduler-controlplane               kube-system
914c342d2412c       ff4f56c76b82d       4 minutes ago       Running             kube-controller-manager   2                   c37c634012222       kube-controller-manager-controlplane      kube-system
167b0946f571b       1cf5f116067c6       4 hours ago         Running             coredns                   1                   895eef49aacc1       coredns-6ff97d97f9-85m5c                  kube-system
d95ca82081ac0       1cf5f116067c6       4 hours ago         Running             coredns                   1                   991a9bbcb876d       coredns-6ff97d97f9-2rxsf                  kube-system
bf0ff3d39592c       3461b62f768ea       4 hours ago         Running             local-path-provisioner    1                   b967b24996b9d       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
9959fa9e11566       e6ea68648f0cd       4 hours ago         Running             kube-flannel              1                   7e5ab3107fb37       canal-rtfc5                               kube-system
3268c994911f6       75392e3500e36       4 hours ago         Running             calico-node               1                   7e5ab3107fb37       canal-rtfc5                               kube-system
aa945d6c206f8       661d404f36f01       4 hours ago         Running             kube-proxy                1                   eda3bc95bfbc8       kube-proxy-7kdz8                          kube-system
50481e2aa1688       499038711c081       4 hours ago         Running             etcd                      1                   c3513ccff356d       etcd-controlplane                         kube-system
controlplane:/var/log/containers$ crictl ps -a
CONTAINER           IMAGE               CREATED              STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
71c23b9b086dc       f9c3c1813269c       About a minute ago   Exited              calico-kube-controllers   5                   af4829eda0445       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
1bb8f023e594d       ee794efa53d85       About a minute ago   Exited              kube-apiserver            5                   6d0b65d8ad780       kube-apiserver-controlplane               kube-system
0a888fc47a665       cfed1ff748928       5 minutes ago        Running             kube-scheduler            2                   c811356bfbc40       kube-scheduler-controlplane               kube-system
914c342d2412c       ff4f56c76b82d       5 minutes ago        Running             kube-controller-manager   2                   c37c634012222       kube-controller-manager-controlplane      kube-system
167b0946f571b       1cf5f116067c6       4 hours ago          Running             coredns                   1                   895eef49aacc1       coredns-6ff97d97f9-85m5c                  kube-system
d95ca82081ac0       1cf5f116067c6       4 hours ago          Running             coredns                   1                   991a9bbcb876d       coredns-6ff97d97f9-2rxsf                  kube-system
bf0ff3d39592c       3461b62f768ea       4 hours ago          Running             local-path-provisioner    1                   b967b24996b9d       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
9959fa9e11566       e6ea68648f0cd       4 hours ago          Running             kube-flannel              1                   7e5ab3107fb37       canal-rtfc5                               kube-system
3268c994911f6       75392e3500e36       4 hours ago          Running             calico-node               1                   7e5ab3107fb37       canal-rtfc5                               kube-system
ef49bbf92b4be       75392e3500e36       4 hours ago          Exited              mount-bpffs               0                   7e5ab3107fb37       canal-rtfc5                               kube-system
f75d43a9da7b3       67fd9ab484510       4 hours ago          Exited              install-cni               2                   7e5ab3107fb37       canal-rtfc5                               kube-system
aa945d6c206f8       661d404f36f01       4 hours ago          Running             kube-proxy                1                   eda3bc95bfbc8       kube-proxy-7kdz8                          kube-system
dfb2955cbb306       ff4f56c76b82d       4 hours ago          Exited              kube-controller-manager   1                   c37c634012222       kube-controller-manager-controlplane      kube-system
43dc491013e5f       cfed1ff748928       4 hours ago          Exited              kube-scheduler            1                   c811356bfbc40       kube-scheduler-controlplane               kube-system
50481e2aa1688       499038711c081       4 hours ago          Running             etcd                      1                   c3513ccff356d       etcd-controlplane                         kube-system
bc5709afb8c2a       3461b62f768ea       3 days ago           Exited              local-path-provisioner    0                   e1478116c3bca       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
ad415e1704cf1       499038711c081       3 days ago           Exited              etcd                      0                   380ec7a73663d       etcd-controlplane                         kube-system
fc8002a7d28c0       1cf5f116067c6       3 days ago           Exited              coredns                   0                   846b6b610bb4b       coredns-6ff97d97f9-2rxsf                  kube-system
824511e16580b       1cf5f116067c6       3 days ago           Exited              coredns                   0                   d105d1a4935b0       coredns-6ff97d97f9-85m5c                  kube-system
d086b88a2535a       e6ea68648f0cd       3 days ago           Exited              kube-flannel              0                   f97ce3fd667bb       canal-rtfc5                               kube-system
acb3df6824931       75392e3500e36       3 days ago           Exited              calico-node               0                   f97ce3fd667bb       canal-rtfc5                               kube-system
4c881ddd2fd7d       661d404f36f01       3 days ago           Exited              kube-proxy                0                   158ad713edb53       kube-proxy-7kdz8                          kube-system
controlplane:/var/log/containers$ crictl ps -a | grep apiserver
1bb8f023e594d       ee794efa53d85       About a minute ago   Exited              kube-apiserver            5                   6d0b65d8ad780       kube-apiserver-controlplane               kube-system
controlplane:/var/log/containers$ crictl logs 6d0b65d8ad780
E0823 02:52:41.525804  112424 log.go:32] "ContainerStatus from runtime service failed" err="rpc error: code = NotFound desc = an error occurred when try to find container \"6d0b65d8ad780\": not found" containerID="6d0b65d8ad780"
FATA[0000] rpc error: code = NotFound desc = an error occurred when try to find container "6d0b65d8ad780": not found 
controlplane:/var/log/containers$ crictl logs 1bb8f023e594d
Error: unknown flag: --this-is-very-wrong
controlplane:/var/log/containers$ cd /etc/kubernetes/manifests/
controlplane:/etc/kubernetes/manifests$ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
controlplane:/etc/kubernetes/manifests$ vi kube-apiserver.yaml 
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ kubectl get pods -A
NAMESPACE            NAME                                      READY   STATUS             RESTARTS        AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   0/1     CrashLoopBackOff   7 (2m51s ago)   3d17h
kube-system          canal-rtfc5                               2/2     Running            2 (3h49m ago)   3d17h
kube-system          coredns-6ff97d97f9-2rxsf                  1/1     Running            1 (3h49m ago)   3d17h
kube-system          coredns-6ff97d97f9-85m5c                  1/1     Running            1 (3h49m ago)   3d17h
kube-system          etcd-controlplane                         1/1     Running            1 (3h49m ago)   3d17h
kube-system          kube-apiserver-controlplane               0/1     Running            0               3d17h
kube-system          kube-controller-manager-controlplane      1/1     Running            2 (12m ago)     3d17h
kube-system          kube-proxy-7kdz8                          1/1     Running            1 (3h49m ago)   3d17h
kube-system          kube-scheduler-controlplane               0/1     Running            2 (12m ago)     3d17h
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running            1 (3h49m ago)   3d17h
controlplane:/etc/kubernetes/manifests$ cat kube-apiserver.yaml 
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.30.1.2:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.30.1.2
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: registry.k8s.io/kube-apiserver:v1.33.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    readinessProbe:
      failureThreshold: 3
      httpGet:
        host: 172.30.1.2
        path: /readyz
        port: 6443
        scheme: HTTPS
      periodSeconds: 1
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 50m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
status: {}
controlplane:/etc/kubernetes/manifests$ 






controlplane:/etc/kubernetes/manifests$ vi kube-apiserver.yaml
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ cd /var/logs/
bash: cd: /var/logs/: No such file or directory
controlplane:/etc/kubernetes/manifests$ cd /var/log
controlplane:/var/log$ ls
README            apt                    containers    dmesg.1.gz      killercoda  syslog
Xorg.0.log        auth.log               cups          dmesg.2.gz      landscape   sysstat
alternatives.log  btmp                   cups-browsed  dpkg.log        lastlog     unattended-upgrades
apport.log        calico                 dist-upgrade  fontconfig.log  lightdm     wtmp
apport.log.1      cloud-init-output.log  dmesg         journal         pods
apport.log.2.gz   cloud-init.log         dmesg.0       kern.log        private
controlplane:/var/log$ cd pods
controlplane:/var/log/pods$ ls
kube-system_calico-kube-controllers-fdf5f5495-8jbqm_7ac5e0c1-e88f-4814-aeaa-db71d4a41248
kube-system_canal-rtfc5_c1f261ea-9cbf-43ca-885e-7c7811b8d5f6
kube-system_coredns-6ff97d97f9-2rxsf_2001369b-a888-4bdd-8555-c8d026262009
kube-system_coredns-6ff97d97f9-85m5c_7eef878c-2943-4bf3-be3c-a442c8c1eedb
kube-system_etcd-controlplane_0a20c757572c0a1fc40cf46300cfcf97
kube-system_kube-apiserver-controlplane_06b9c421316358c8a83daeddc1f70dbe
kube-system_kube-controller-manager-controlplane_bc2d002eef4f6ab030edec4bdf370f16
kube-system_kube-proxy-7kdz8_e7ad3206-b5e2-43c4-8f7a-6380b39e9208
kube-system_kube-scheduler-controlplane_3bfb9bf8f1e4a4dbe1a89a770e151a87
local-path-storage_local-path-provisioner-5c94487ccb-gmwjg_90bd1749-4aa8-4158-bc70-7f85e1b31626
controlplane:/var/log/pods$ cd /var/log/containers/
controlplane:/var/log/containers$ ls
calico-kube-controllers-fdf5f5495-8jbqm_kube-system_calico-kube-controllers-3bc249666b81af131f43a94f708b2e0d4970308d9ed017e73fffd00ab4ed926e.log
calico-kube-controllers-fdf5f5495-8jbqm_kube-system_calico-kube-controllers-9d703e7fe07df0c5b1690574c65da45e2b596f44fdd8341d695edba0da24b127.log
canal-rtfc5_kube-system_calico-node-3268c994911f6f0dee943bc20ae3144c845a935552860a26117113f766f43a6b.log
canal-rtfc5_kube-system_calico-node-acb3df6824931ff8bec6741d13d6fe0813d0b58e80d258d0f4cd510938a8830a.log
canal-rtfc5_kube-system_install-cni-f75d43a9da7b3b70a7344153f01d2acdcb73e068283c2beafdf75427fe2e3e42.log
canal-rtfc5_kube-system_kube-flannel-9959fa9e11566c57654d19aa5fc4c9c64112714ba2c17eccadbb2d977a17b6bd.log
canal-rtfc5_kube-system_kube-flannel-d086b88a2535aca10c52918b1280854ce4ae06a162218160c8a25a57333643a4.log
canal-rtfc5_kube-system_mount-bpffs-ef49bbf92b4bea2c60abe7c19c37a972fb728735724b3afa4e25bdb9c17dff8c.log
coredns-6ff97d97f9-2rxsf_kube-system_coredns-d95ca82081ac05e596372c70038b9b26ebfe2cc35f23fe39bc5fedb89c8c556f.log
coredns-6ff97d97f9-2rxsf_kube-system_coredns-fc8002a7d28c01d4a476af330bbf73bc8ffbe6f0bce06b0868742f162f4dead3.log
coredns-6ff97d97f9-85m5c_kube-system_coredns-167b0946f571b21fe66d072cb245861c0fa797851d7d57bb4befe9c7d600ebf5.log
coredns-6ff97d97f9-85m5c_kube-system_coredns-824511e16580b582fe03ffd795200474babec06be472cc3f77e9c8a3b4cd58a1.log
etcd-controlplane_kube-system_etcd-50481e2aa1688d9258ce8567f667b3b5c9eec3b7b0bee8e9db3e6c398cdc75fb.log
etcd-controlplane_kube-system_etcd-ad415e1704cf13d5407a7944cd621b76e18e5e8de4b9e31e8448da1c7c72a433.log
kube-apiserver-controlplane_kube-system_kube-apiserver-96b15d6405ad7eb312d9cbc916389adc5ac73324f49d180ff0436bb990534e85.log
kube-controller-manager-controlplane_kube-system_kube-controller-manager-914c342d2412cb057b96b56bda09ecda070edeff2e324efa0b75adadd49ed376.log
kube-controller-manager-controlplane_kube-system_kube-controller-manager-a74dbda2e72478627ed0d7ffe071cf827973148e0924489472e6401fe310cec5.log
kube-proxy-7kdz8_kube-system_kube-proxy-4c881ddd2fd7df9becf4d4b6eee7b77b3066410a7e3b0f7e8c29a7f52780562e.log
kube-proxy-7kdz8_kube-system_kube-proxy-aa945d6c206f8b28dc1094c17ce54bf4797c07cb5c1eb756762d32b74504f6b4.log
kube-scheduler-controlplane_kube-system_kube-scheduler-0a888fc47a665facb8e2571142d1982e830eeef9bc43f82d460b37d90fa0a3d4.log
kube-scheduler-controlplane_kube-system_kube-scheduler-dc236e267072839abe3f18db9422fc00c470eb05faa64e8b72a1de89ebcdef6e.log
local-path-provisioner-5c94487ccb-gmwjg_local-path-storage_local-path-provisioner-bc5709afb8c2a6ff217483862211a16d559e48ac20e6303d6a18c51ef6560ab4.log
local-path-provisioner-5c94487ccb-gmwjg_local-path-storage_local-path-provisioner-bf0ff3d39592c7b05f05a8e2f6215569c20b5ebfa56a26627b0a1980198575b4.log
controlplane:/var/log/containers$ cat kube-apiserver-controlplane_kube-system_kube-apiserver-96b15d6405ad7eb312d9cbc916389adc5ac73324f49d180ff0436bb990534e85.log 
2025-08-23T03:03:59.260410863Z stderr F I0823 03:03:59.258654       1 options.go:249] external host was not specified, using 172.30.1.2
2025-08-23T03:03:59.260456123Z stderr F I0823 03:03:59.260222       1 server.go:147] Version: v1.33.2
2025-08-23T03:03:59.260459768Z stderr F I0823 03:03:59.260242       1 server.go:149] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
2025-08-23T03:03:59.530035723Z stderr F I0823 03:03:59.529940       1 plugins.go:157] Loaded 14 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,PodTopologyLabels,MutatingAdmissionPolicy,MutatingAdmissionWebhook.
2025-08-23T03:03:59.530152037Z stderr F I0823 03:03:59.530112       1 plugins.go:160] Loaded 13 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,PodSecurity,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,ClusterTrustBundleAttest,CertificateSubjectRestriction,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook,ResourceQuota.
2025-08-23T03:03:59.530603292Z stderr F I0823 03:03:59.530564       1 instance.go:233] Using reconciler: lease
2025-08-23T03:03:59.531073676Z stderr F I0823 03:03:59.531033       1 shared_informer.go:350] "Waiting for caches to sync" controller="node_authorizer"
2025-08-23T03:03:59.531893268Z stderr F I0823 03:03:59.531841       1 shared_informer.go:350] "Waiting for caches to sync" controller="*generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]"
2025-08-23T03:03:59.576112419Z stderr F I0823 03:03:59.576038       1 handler.go:288] Adding GroupVersion apiextensions.k8s.io v1 to ResourceManager
2025-08-23T03:03:59.576214746Z stderr F W0823 03:03:59.576188       1 genericapiserver.go:778] Skipping API apiextensions.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:03:59.60606832Z stderr F I0823 03:03:59.605999       1 cidrallocator.go:197] starting ServiceCIDR Allocator Controller
2025-08-23T03:03:59.749392429Z stderr F I0823 03:03:59.749289       1 handler.go:288] Adding GroupVersion  v1 to ResourceManager
2025-08-23T03:03:59.749808178Z stderr F I0823 03:03:59.749763       1 apis.go:112] API group "internal.apiserver.k8s.io" is not enabled, skipping.
2025-08-23T03:03:59.941100639Z stderr F I0823 03:03:59.941018       1 apis.go:112] API group "storagemigration.k8s.io" is not enabled, skipping.
2025-08-23T03:04:00.0295627Z stderr F I0823 03:04:00.029464       1 apis.go:112] API group "resource.k8s.io" is not enabled, skipping.
2025-08-23T03:04:00.050281676Z stderr F I0823 03:04:00.050202       1 handler.go:288] Adding GroupVersion authentication.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.050401866Z stderr F W0823 03:04:00.050353       1 genericapiserver.go:778] Skipping API authentication.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.050434386Z stderr F W0823 03:04:00.050419       1 genericapiserver.go:778] Skipping API authentication.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.050895237Z stderr F I0823 03:04:00.050861       1 handler.go:288] Adding GroupVersion authorization.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.050930468Z stderr F W0823 03:04:00.050915       1 genericapiserver.go:778] Skipping API authorization.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.051736972Z stderr F I0823 03:04:00.051708       1 handler.go:288] Adding GroupVersion autoscaling v2 to ResourceManager
2025-08-23T03:04:00.05241714Z stderr F I0823 03:04:00.052381       1 handler.go:288] Adding GroupVersion autoscaling v1 to ResourceManager
2025-08-23T03:04:00.052467127Z stderr F W0823 03:04:00.052447       1 genericapiserver.go:778] Skipping API autoscaling/v2beta1 because it has no resources.
2025-08-23T03:04:00.052535023Z stderr F W0823 03:04:00.052502       1 genericapiserver.go:778] Skipping API autoscaling/v2beta2 because it has no resources.
2025-08-23T03:04:00.054533508Z stderr F I0823 03:04:00.054477       1 handler.go:288] Adding GroupVersion batch v1 to ResourceManager
2025-08-23T03:04:00.054607486Z stderr F W0823 03:04:00.054577       1 genericapiserver.go:778] Skipping API batch/v1beta1 because it has no resources.
2025-08-23T03:04:00.056265232Z stderr F I0823 03:04:00.055978       1 handler.go:288] Adding GroupVersion certificates.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.05627693Z stderr F W0823 03:04:00.056000       1 genericapiserver.go:778] Skipping API certificates.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.056278746Z stderr F W0823 03:04:00.056003       1 genericapiserver.go:778] Skipping API certificates.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.057319456Z stderr F I0823 03:04:00.057209       1 handler.go:288] Adding GroupVersion coordination.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.057438876Z stderr F W0823 03:04:00.057403       1 genericapiserver.go:778] Skipping API coordination.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.057471646Z stderr F W0823 03:04:00.057456       1 genericapiserver.go:778] Skipping API coordination.k8s.io/v1alpha2 because it has no resources.
2025-08-23T03:04:00.058951166Z stderr F I0823 03:04:00.058871       1 handler.go:288] Adding GroupVersion discovery.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.059058011Z stderr F W0823 03:04:00.059028       1 genericapiserver.go:778] Skipping API discovery.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.069568868Z stderr F I0823 03:04:00.069504       1 handler.go:288] Adding GroupVersion networking.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.069901314Z stderr F W0823 03:04:00.069861       1 genericapiserver.go:778] Skipping API networking.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.069950322Z stderr F W0823 03:04:00.069932       1 genericapiserver.go:778] Skipping API networking.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.070428025Z stderr F I0823 03:04:00.070369       1 handler.go:288] Adding GroupVersion node.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.070658321Z stderr F W0823 03:04:00.070623       1 genericapiserver.go:778] Skipping API node.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.070709132Z stderr F W0823 03:04:00.070685       1 genericapiserver.go:778] Skipping API node.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.071249801Z stderr F I0823 03:04:00.071215       1 handler.go:288] Adding GroupVersion policy v1 to ResourceManager
2025-08-23T03:04:00.071287316Z stderr F W0823 03:04:00.071272       1 genericapiserver.go:778] Skipping API policy/v1beta1 because it has no resources.
2025-08-23T03:04:00.072285889Z stderr F I0823 03:04:00.072234       1 handler.go:288] Adding GroupVersion rbac.authorization.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.072402914Z stderr F W0823 03:04:00.072352       1 genericapiserver.go:778] Skipping API rbac.authorization.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.072434829Z stderr F W0823 03:04:00.072419       1 genericapiserver.go:778] Skipping API rbac.authorization.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.072877063Z stderr F I0823 03:04:00.072836       1 handler.go:288] Adding GroupVersion scheduling.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.072953413Z stderr F W0823 03:04:00.072913       1 genericapiserver.go:778] Skipping API scheduling.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.072991797Z stderr F W0823 03:04:00.072971       1 genericapiserver.go:778] Skipping API scheduling.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.074528476Z stderr F I0823 03:04:00.074465       1 handler.go:288] Adding GroupVersion storage.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.074661436Z stderr F W0823 03:04:00.074608       1 genericapiserver.go:778] Skipping API storage.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.074711219Z stderr F W0823 03:04:00.074688       1 genericapiserver.go:778] Skipping API storage.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.075796509Z stderr F I0823 03:04:00.075725       1 handler.go:288] Adding GroupVersion flowcontrol.apiserver.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.075888963Z stderr F W0823 03:04:00.075859       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta3 because it has no resources.
2025-08-23T03:04:00.075963095Z stderr F W0823 03:04:00.075927       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta2 because it has no resources.
2025-08-23T03:04:00.076010288Z stderr F W0823 03:04:00.075988       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.078682891Z stderr F I0823 03:04:00.078606       1 handler.go:288] Adding GroupVersion apps v1 to ResourceManager
2025-08-23T03:04:00.078772113Z stderr F W0823 03:04:00.078748       1 genericapiserver.go:778] Skipping API apps/v1beta2 because it has no resources.
2025-08-23T03:04:00.078812861Z stderr F W0823 03:04:00.078789       1 genericapiserver.go:778] Skipping API apps/v1beta1 because it has no resources.
2025-08-23T03:04:00.080267004Z stderr F I0823 03:04:00.080172       1 handler.go:288] Adding GroupVersion admissionregistration.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.080373008Z stderr F W0823 03:04:00.080345       1 genericapiserver.go:778] Skipping API admissionregistration.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.08044189Z stderr F W0823 03:04:00.080413       1 genericapiserver.go:778] Skipping API admissionregistration.k8s.io/v1alpha1 because it has no resources.
2025-08-23T03:04:00.080862485Z stderr F I0823 03:04:00.080820       1 handler.go:288] Adding GroupVersion events.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.080910704Z stderr F W0823 03:04:00.080887       1 genericapiserver.go:778] Skipping API events.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.088644114Z stderr F I0823 03:04:00.088565       1 handler.go:288] Adding GroupVersion apiregistration.k8s.io v1 to ResourceManager
2025-08-23T03:04:00.088738772Z stderr F W0823 03:04:00.088707       1 genericapiserver.go:778] Skipping API apiregistration.k8s.io/v1beta1 because it has no resources.
2025-08-23T03:04:00.558046554Z stderr F I0823 03:04:00.557944       1 secure_serving.go:211] Serving securely on [::]:6443
2025-08-23T03:04:00.558875215Z stderr F I0823 03:04:00.558551       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/pki/front-proxy-ca.crt"
2025-08-23T03:04:00.558922269Z stderr F I0823 03:04:00.558649       1 dynamic_serving_content.go:135] "Starting controller" name="serving-cert::/etc/kubernetes/pki/apiserver.crt::/etc/kubernetes/pki/apiserver.key"
2025-08-23T03:04:00.558943867Z stderr F I0823 03:04:00.558692       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
2025-08-23T03:04:00.562670339Z stderr F I0823 03:04:00.562523       1 gc_controller.go:78] Starting apiserver lease garbage collector
2025-08-23T03:04:00.56315924Z stderr F I0823 03:04:00.563047       1 controller.go:119] Starting legacy_token_tracking_controller
2025-08-23T03:04:00.563620122Z stderr F I0823 03:04:00.563230       1 shared_informer.go:350] "Waiting for caches to sync" controller="configmaps"
2025-08-23T03:04:00.563636824Z stderr F I0823 03:04:00.563578       1 controller.go:80] Starting OpenAPI V3 AggregationController
2025-08-23T03:04:00.564408057Z stderr F I0823 03:04:00.564369       1 apf_controller.go:377] Starting API Priority and Fairness config controller
2025-08-23T03:04:00.564487625Z stderr F I0823 03:04:00.564469       1 system_namespaces_controller.go:66] Starting system namespaces controller
2025-08-23T03:04:00.564632105Z stderr F I0823 03:04:00.564601       1 cluster_authentication_trust_controller.go:459] Starting cluster_authentication_trust_controller controller
2025-08-23T03:04:00.564708909Z stderr F I0823 03:04:00.564649       1 shared_informer.go:350] "Waiting for caches to sync" controller="cluster_authentication_trust_controller"
2025-08-23T03:04:00.566337069Z stderr F I0823 03:04:00.564950       1 customresource_discovery_controller.go:294] Starting DiscoveryController
2025-08-23T03:04:00.566396279Z stderr F I0823 03:04:00.564978       1 dynamic_serving_content.go:135] "Starting controller" name="aggregator-proxy-cert::/etc/kubernetes/pki/front-proxy-client.crt::/etc/kubernetes/pki/front-proxy-client.key"
2025-08-23T03:04:00.566412319Z stderr F I0823 03:04:00.565022       1 local_available_controller.go:156] Starting LocalAvailability controller
2025-08-23T03:04:00.56641697Z stderr F I0823 03:04:00.565026       1 cache.go:32] Waiting for caches to sync for LocalAvailability controller
2025-08-23T03:04:00.566421108Z stderr F I0823 03:04:00.565039       1 remote_available_controller.go:411] Starting RemoteAvailability controller
2025-08-23T03:04:00.566424853Z stderr F I0823 03:04:00.565042       1 cache.go:32] Waiting for caches to sync for RemoteAvailability controller
2025-08-23T03:04:00.566428562Z stderr F I0823 03:04:00.565049       1 apiservice_controller.go:100] Starting APIServiceRegistrationController
2025-08-23T03:04:00.566432509Z stderr F I0823 03:04:00.565052       1 cache.go:32] Waiting for caches to sync for APIServiceRegistrationController controller
2025-08-23T03:04:00.566436446Z stderr F I0823 03:04:00.565060       1 aggregator.go:169] waiting for initial CRD sync...
2025-08-23T03:04:00.566440696Z stderr F I0823 03:04:00.565066       1 controller.go:78] Starting OpenAPI AggregationController
2025-08-23T03:04:00.566442544Z stderr F I0823 03:04:00.565085       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
2025-08-23T03:04:00.580304865Z stderr F I0823 03:04:00.580141       1 default_servicecidr_controller.go:110] Starting kubernetes-service-cidr-controller
2025-08-23T03:04:00.581086528Z stderr F I0823 03:04:00.581046       1 shared_informer.go:350] "Waiting for caches to sync" controller="kubernetes-service-cidr-controller"
2025-08-23T03:04:00.581180509Z stderr F I0823 03:04:00.581129       1 repairip.go:200] Starting ipallocator-repair-controller
2025-08-23T03:04:00.581217467Z stderr F I0823 03:04:00.581196       1 shared_informer.go:350] "Waiting for caches to sync" controller="ipallocator-repair-controller"
2025-08-23T03:04:00.582342817Z stderr F I0823 03:04:00.581471       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
2025-08-23T03:04:00.582353617Z stderr F I0823 03:04:00.581517       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/pki/front-proxy-ca.crt"
2025-08-23T03:04:00.5823556Z stderr F I0823 03:04:00.581727       1 controller.go:142] Starting OpenAPI controller
2025-08-23T03:04:00.582356982Z stderr F I0823 03:04:00.581743       1 controller.go:90] Starting OpenAPI V3 controller
2025-08-23T03:04:00.582358394Z stderr F I0823 03:04:00.581751       1 naming_controller.go:299] Starting NamingConditionController
2025-08-23T03:04:00.582359676Z stderr F I0823 03:04:00.581760       1 establishing_controller.go:81] Starting EstablishingController
2025-08-23T03:04:00.582361125Z stderr F I0823 03:04:00.581767       1 nonstructuralschema_controller.go:195] Starting NonStructuralSchemaConditionController
2025-08-23T03:04:00.582362395Z stderr F I0823 03:04:00.581772       1 apiapproval_controller.go:189] Starting KubernetesAPIApprovalPolicyConformantConditionController
2025-08-23T03:04:00.582363753Z stderr F I0823 03:04:00.581781       1 crd_finalizer.go:269] Starting CRDFinalizer
2025-08-23T03:04:00.582365215Z stderr F I0823 03:04:00.581962       1 crdregistration_controller.go:114] Starting crd-autoregister controller
2025-08-23T03:04:00.582366513Z stderr F I0823 03:04:00.581966       1 shared_informer.go:350] "Waiting for caches to sync" controller="crd-autoregister"
2025-08-23T03:04:00.735040785Z stderr F I0823 03:04:00.734945       1 shared_informer.go:357] "Caches are synced" controller="*generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]"
2025-08-23T03:04:00.735186852Z stderr F I0823 03:04:00.735136       1 policy_source.go:240] refreshing policies
2025-08-23T03:04:00.735271086Z stderr F I0823 03:04:00.735227       1 shared_informer.go:357] "Caches are synced" controller="node_authorizer"
2025-08-23T03:04:00.763540149Z stderr F I0823 03:04:00.763372       1 shared_informer.go:357] "Caches are synced" controller="configmaps"
2025-08-23T03:04:00.764779616Z stderr F I0823 03:04:00.764706       1 shared_informer.go:357] "Caches are synced" controller="cluster_authentication_trust_controller"
2025-08-23T03:04:00.764965952Z stderr F I0823 03:04:00.764934       1 apf_controller.go:382] Running API Priority and Fairness config worker
2025-08-23T03:04:00.765010612Z stderr F I0823 03:04:00.764994       1 apf_controller.go:385] Running API Priority and Fairness periodic rebalancing process
2025-08-23T03:04:00.765109324Z stderr F I0823 03:04:00.765088       1 handler.go:288] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
2025-08-23T03:04:00.765764169Z stderr F I0823 03:04:00.765726       1 cache.go:39] Caches are synced for APIServiceRegistrationController controller
2025-08-23T03:04:00.769463889Z stderr F I0823 03:04:00.769365       1 cache.go:39] Caches are synced for LocalAvailability controller
2025-08-23T03:04:00.769699362Z stderr F I0823 03:04:00.769662       1 cache.go:39] Caches are synced for RemoteAvailability controller
2025-08-23T03:04:00.769923406Z stderr F I0823 03:04:00.769886       1 handler_discovery.go:451] Starting ResourceDiscoveryManager
2025-08-23T03:04:00.782084637Z stderr F I0823 03:04:00.782012       1 shared_informer.go:357] "Caches are synced" controller="crd-autoregister"
2025-08-23T03:04:00.782281732Z stderr F I0823 03:04:00.782252       1 shared_informer.go:357] "Caches are synced" controller="kubernetes-service-cidr-controller"
2025-08-23T03:04:00.782358529Z stderr F I0823 03:04:00.782335       1 default_servicecidr_controller.go:136] Shutting down kubernetes-service-cidr-controller
2025-08-23T03:04:00.79872128Z stderr F I0823 03:04:00.798573       1 shared_informer.go:357] "Caches are synced" controller="ipallocator-repair-controller"
2025-08-23T03:04:00.81470187Z stderr F I0823 03:04:00.814619       1 aggregator.go:171] initial CRD sync complete...
2025-08-23T03:04:00.814802369Z stderr F I0823 03:04:00.814773       1 autoregister_controller.go:144] Starting autoregister controller
2025-08-23T03:04:00.814845017Z stderr F I0823 03:04:00.814818       1 cache.go:32] Waiting for caches to sync for autoregister controller
2025-08-23T03:04:00.814878307Z stderr F I0823 03:04:00.814859       1 cache.go:39] Caches are synced for autoregister controller
2025-08-23T03:04:00.834683154Z stderr F I0823 03:04:00.834584       1 controller.go:667] quota admission added evaluator for: leases.coordination.k8s.io
2025-08-23T03:04:00.835250405Z stderr F I0823 03:04:00.835202       1 cidrallocator.go:301] created ClusterIP allocator for Service CIDR 10.96.0.0/12
2025-08-23T03:04:01.573850796Z stderr F I0823 03:04:01.573768       1 storage_scheduling.go:111] all system priority classes are created successfully or already exist.
2025-08-23T03:04:01.778777471Z stderr F W0823 03:04:01.778597       1 lease.go:265] Resetting endpoints for master service "kubernetes" to [172.30.1.2]
2025-08-23T03:04:01.779822278Z stderr F I0823 03:04:01.779755       1 controller.go:667] quota admission added evaluator for: endpoints
2025-08-23T03:04:01.786131443Z stderr F I0823 03:04:01.786033       1 controller.go:667] quota admission added evaluator for: endpointslices.discovery.k8s.io
2025-08-23T03:04:18.827842361Z stderr F I0823 03:04:18.827756       1 controller.go:667] quota admission added evaluator for: serviceaccounts
2025-08-23T03:04:20.18075191Z stderr F I0823 03:04:20.180680       1 cidrallocator.go:277] updated ClusterIP allocator for Service CIDR 10.96.0.0/12
2025-08-23T03:04:20.347575945Z stderr F I0823 03:04:20.347470       1 controller.go:667] quota admission added evaluator for: replicasets.apps
2025-08-23T03:04:20.44305054Z stderr F I0823 03:04:20.442935       1 controller.go:667] quota admission added evaluator for: deployments.apps
2025-08-23T03:04:20.543231489Z stderr F I0823 03:04:20.543136       1 controller.go:667] quota admission added evaluator for: poddisruptionbudgets.policy
controlplane:/var/log/containers$ crictl ps
CONTAINER           IMAGE               CREATED              STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
3bc249666b81a       f9c3c1813269c       About a minute ago   Running             calico-kube-controllers   9                   af4829eda0445       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
96b15d6405ad7       ee794efa53d85       2 minutes ago        Running             kube-apiserver            0                   385446d894ee2       kube-apiserver-controlplane               kube-system
a74dbda2e7247       ff4f56c76b82d       2 minutes ago        Running             kube-controller-manager   3                   c37c634012222       kube-controller-manager-controlplane      kube-system
dc236e2670728       cfed1ff748928       2 minutes ago        Running             kube-scheduler            3                   c811356bfbc40       kube-scheduler-controlplane               kube-system
167b0946f571b       1cf5f116067c6       4 hours ago          Running             coredns                   1                   895eef49aacc1       coredns-6ff97d97f9-85m5c                  kube-system
d95ca82081ac0       1cf5f116067c6       4 hours ago          Running             coredns                   1                   991a9bbcb876d       coredns-6ff97d97f9-2rxsf                  kube-system
bf0ff3d39592c       3461b62f768ea       4 hours ago          Running             local-path-provisioner    1                   b967b24996b9d       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
9959fa9e11566       e6ea68648f0cd       4 hours ago          Running             kube-flannel              1                   7e5ab3107fb37       canal-rtfc5                               kube-system
3268c994911f6       75392e3500e36       4 hours ago          Running             calico-node               1                   7e5ab3107fb37       canal-rtfc5                               kube-system
aa945d6c206f8       661d404f36f01       4 hours ago          Running             kube-proxy                1                   eda3bc95bfbc8       kube-proxy-7kdz8                          kube-system
50481e2aa1688       499038711c081       4 hours ago          Running             etcd                      1                   c3513ccff356d       etcd-controlplane                         kube-system
controlplane:/var/log/containers$ crictl ps -a
CONTAINER           IMAGE               CREATED              STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
3bc249666b81a       f9c3c1813269c       About a minute ago   Running             calico-kube-controllers   9                   af4829eda0445       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
96b15d6405ad7       ee794efa53d85       2 minutes ago        Running             kube-apiserver            0                   385446d894ee2       kube-apiserver-controlplane               kube-system
a74dbda2e7247       ff4f56c76b82d       2 minutes ago        Running             kube-controller-manager   3                   c37c634012222       kube-controller-manager-controlplane      kube-system
dc236e2670728       cfed1ff748928       2 minutes ago        Running             kube-scheduler            3                   c811356bfbc40       kube-scheduler-controlplane               kube-system
9d703e7fe07df       f9c3c1813269c       3 minutes ago        Exited              calico-kube-controllers   8                   af4829eda0445       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
0a888fc47a665       cfed1ff748928       19 minutes ago       Exited              kube-scheduler            2                   c811356bfbc40       kube-scheduler-controlplane               kube-system
914c342d2412c       ff4f56c76b82d       19 minutes ago       Exited              kube-controller-manager   2                   c37c634012222       kube-controller-manager-controlplane      kube-system
167b0946f571b       1cf5f116067c6       4 hours ago          Running             coredns                   1                   895eef49aacc1       coredns-6ff97d97f9-85m5c                  kube-system
d95ca82081ac0       1cf5f116067c6       4 hours ago          Running             coredns                   1                   991a9bbcb876d       coredns-6ff97d97f9-2rxsf                  kube-system
bf0ff3d39592c       3461b62f768ea       4 hours ago          Running             local-path-provisioner    1                   b967b24996b9d       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
9959fa9e11566       e6ea68648f0cd       4 hours ago          Running             kube-flannel              1                   7e5ab3107fb37       canal-rtfc5                               kube-system
3268c994911f6       75392e3500e36       4 hours ago          Running             calico-node               1                   7e5ab3107fb37       canal-rtfc5                               kube-system
ef49bbf92b4be       75392e3500e36       4 hours ago          Exited              mount-bpffs               0                   7e5ab3107fb37       canal-rtfc5                               kube-system
f75d43a9da7b3       67fd9ab484510       4 hours ago          Exited              install-cni               2                   7e5ab3107fb37       canal-rtfc5                               kube-system
aa945d6c206f8       661d404f36f01       4 hours ago          Running             kube-proxy                1                   eda3bc95bfbc8       kube-proxy-7kdz8                          kube-system
50481e2aa1688       499038711c081       4 hours ago          Running             etcd                      1                   c3513ccff356d       etcd-controlplane                         kube-system
bc5709afb8c2a       3461b62f768ea       3 days ago           Exited              local-path-provisioner    0                   e1478116c3bca       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
ad415e1704cf1       499038711c081       3 days ago           Exited              etcd                      0                   380ec7a73663d       etcd-controlplane                         kube-system
fc8002a7d28c0       1cf5f116067c6       3 days ago           Exited              coredns                   0                   846b6b610bb4b       coredns-6ff97d97f9-2rxsf                  kube-system
824511e16580b       1cf5f116067c6       3 days ago           Exited              coredns                   0                   d105d1a4935b0       coredns-6ff97d97f9-85m5c                  kube-system
d086b88a2535a       e6ea68648f0cd       3 days ago           Exited              kube-flannel              0                   f97ce3fd667bb       canal-rtfc5                               kube-system
acb3df6824931       75392e3500e36       3 days ago           Exited              calico-node               0                   f97ce3fd667bb       canal-rtfc5                               kube-system
4c881ddd2fd7d       661d404f36f01       3 days ago           Exited              kube-proxy                0                   158ad713edb53       kube-proxy-7kdz8                          kube-system
controlplane:/var/log/containers$ kubectl get pods -A
NAMESPACE            NAME                                      READY   STATUS    RESTARTS        AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   9 (2m23s ago)   3d18h
kube-system          canal-rtfc5                               2/2     Running   2 (3h56m ago)   3d18h
kube-system          coredns-6ff97d97f9-2rxsf                  1/1     Running   1 (3h56m ago)   3d18h
kube-system          coredns-6ff97d97f9-85m5c                  1/1     Running   1 (3h56m ago)   3d18h
kube-system          etcd-controlplane                         1/1     Running   1 (3h56m ago)   3d18h
kube-system          kube-apiserver-controlplane               1/1     Running   0               2m33s
kube-system          kube-controller-manager-controlplane      1/1     Running   3 (3m14s ago)   3d18h
kube-system          kube-proxy-7kdz8                          1/1     Running   1 (3h56m ago)   3d18h
kube-system          kube-scheduler-controlplane               1/1     Running   3 (3m15s ago)   3d18h
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running   1 (3h56m ago)   3d18h
controlplane:/var/log/containers$ cd /etc/kubernetes/manifests/
controlplane:/etc/kubernetes/manifests$ ls
etcd.yaml  kube-apiserver.yaml  kube-apiserver.yaml.ori  kube-controller-manager.yaml  kube-scheduler.yaml
controlplane:/etc/kubernetes/manifests$ vi kube-apiserver.yaml
controlplane:/etc/kubernetes/manifests$ cat kube-apiserver.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.30.1.2:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.30.1.2
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=this-is-very-wrong
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=10.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: registry.k8s.io/kube-apiserver:v1.33.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    readinessProbe:
      failureThreshold: 3
      httpGet:
        host: 172.30.1.2
        path: /readyz
        port: 6443
        scheme: HTTPS
      periodSeconds: 1
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 50m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
status: {}
controlplane:/etc/kubernetes/manifests$ kubectl get pods -A
NAMESPACE            NAME                                      READY   STATUS    RESTARTS        AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   9 (4m57s ago)   3d18h
kube-system          canal-rtfc5                               2/2     Running   2 (3h58m ago)   3d18h
kube-system          coredns-6ff97d97f9-2rxsf                  1/1     Running   1 (3h58m ago)   3d18h
kube-system          coredns-6ff97d97f9-85m5c                  1/1     Running   1 (3h58m ago)   3d18h
kube-system          etcd-controlplane                         1/1     Running   1 (3h58m ago)   3d18h
kube-system          kube-apiserver-controlplane               1/1     Running   0               5m7s
kube-system          kube-controller-manager-controlplane      1/1     Running   3 (5m48s ago)   3d18h
kube-system          kube-proxy-7kdz8                          1/1     Running   1 (3h58m ago)   3d18h
kube-system          kube-scheduler-controlplane               1/1     Running   3 (5m49s ago)   3d18h
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running   1 (3h58m ago)   3d18h
controlplane:/etc/kubernetes/manifests$ k crea
error: unknown command "crea" for "kubectl"

Did you mean this?
        create
controlplane:/etc/kubernetes/manifests$ k create deploy nginx --image nginx
deployment.apps/nginx created
controlplane:/etc/kubernetes/manifests$ k get pods
NAME                     READY   STATUS              RESTARTS   AGE
nginx-5869d7778c-fpdjw   0/1     ContainerCreating   0          3s
controlplane:/etc/kubernetes/manifests$ k get pods
NAME                     READY   STATUS              RESTARTS   AGE
nginx-5869d7778c-fpdjw   0/1     ContainerCreating   0          7s
controlplane:/etc/kubernetes/manifests$ k get pods -w
NAME                     READY   STATUS              RESTARTS   AGE
nginx-5869d7778c-fpdjw   0/1     ContainerCreating   0          11s
nginx-5869d7778c-fpdjw   1/1     Running             0          11s
controlplane:/etc/kubernetes/manifests$ kubectl logs -n kube-system kube-apiserver-controlplanene
I0823 03:03:59.258654       1 options.go:249] external host was not specified, using 172.30.1.2
I0823 03:03:59.260222       1 server.go:147] Version: v1.33.2
I0823 03:03:59.260242       1 server.go:149] "Golang settings" GOGC="" GOMAXPROCS="" GOTRACEBACK=""
I0823 03:03:59.529940       1 plugins.go:157] Loaded 14 mutating admission controller(s) successfully in the following order: NamespaceLifecycle,LimitRanger,ServiceAccount,NodeRestriction,TaintNodesByCondition,Priority,DefaultTolerationSeconds,DefaultStorageClass,StorageObjectInUseProtection,RuntimeClass,DefaultIngressClass,PodTopologyLabels,MutatingAdmissionPolicy,MutatingAdmissionWebhook.
I0823 03:03:59.530112       1 plugins.go:160] Loaded 13 validating admission controller(s) successfully in the following order: LimitRanger,ServiceAccount,PodSecurity,Priority,PersistentVolumeClaimResize,RuntimeClass,CertificateApproval,CertificateSigning,ClusterTrustBundleAttest,CertificateSubjectRestriction,ValidatingAdmissionPolicy,ValidatingAdmissionWebhook,ResourceQuota.
I0823 03:03:59.530564       1 instance.go:233] Using reconciler: lease
I0823 03:03:59.531033       1 shared_informer.go:350] "Waiting for caches to sync" controller="node_authorizer"
I0823 03:03:59.531841       1 shared_informer.go:350] "Waiting for caches to sync" controller="*generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]"
I0823 03:03:59.576038       1 handler.go:288] Adding GroupVersion apiextensions.k8s.io v1 to ResourceManager
W0823 03:03:59.576188       1 genericapiserver.go:778] Skipping API apiextensions.k8s.io/v1beta1 because it has no resources.
I0823 03:03:59.605999       1 cidrallocator.go:197] starting ServiceCIDR Allocator Controller
I0823 03:03:59.749289       1 handler.go:288] Adding GroupVersion  v1 to ResourceManager
I0823 03:03:59.749763       1 apis.go:112] API group "internal.apiserver.k8s.io" is not enabled, skipping.
I0823 03:03:59.941018       1 apis.go:112] API group "storagemigration.k8s.io" is not enabled, skipping.
I0823 03:04:00.029464       1 apis.go:112] API group "resource.k8s.io" is not enabled, skipping.
I0823 03:04:00.050202       1 handler.go:288] Adding GroupVersion authentication.k8s.io v1 to ResourceManager
W0823 03:04:00.050353       1 genericapiserver.go:778] Skipping API authentication.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.050419       1 genericapiserver.go:778] Skipping API authentication.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.050861       1 handler.go:288] Adding GroupVersion authorization.k8s.io v1 to ResourceManager
W0823 03:04:00.050915       1 genericapiserver.go:778] Skipping API authorization.k8s.io/v1beta1 because it has no resources.
I0823 03:04:00.051708       1 handler.go:288] Adding GroupVersion autoscaling v2 to ResourceManager
I0823 03:04:00.052381       1 handler.go:288] Adding GroupVersion autoscaling v1 to ResourceManager
W0823 03:04:00.052447       1 genericapiserver.go:778] Skipping API autoscaling/v2beta1 because it has no resources.
W0823 03:04:00.052502       1 genericapiserver.go:778] Skipping API autoscaling/v2beta2 because it has no resources.
I0823 03:04:00.054477       1 handler.go:288] Adding GroupVersion batch v1 to ResourceManager
W0823 03:04:00.054577       1 genericapiserver.go:778] Skipping API batch/v1beta1 because it has no resources.
I0823 03:04:00.055978       1 handler.go:288] Adding GroupVersion certificates.k8s.io v1 to ResourceManager
W0823 03:04:00.056000       1 genericapiserver.go:778] Skipping API certificates.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.056003       1 genericapiserver.go:778] Skipping API certificates.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.057209       1 handler.go:288] Adding GroupVersion coordination.k8s.io v1 to ResourceManager
W0823 03:04:00.057403       1 genericapiserver.go:778] Skipping API coordination.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.057456       1 genericapiserver.go:778] Skipping API coordination.k8s.io/v1alpha2 because it has no resources.
I0823 03:04:00.058871       1 handler.go:288] Adding GroupVersion discovery.k8s.io v1 to ResourceManager
W0823 03:04:00.059028       1 genericapiserver.go:778] Skipping API discovery.k8s.io/v1beta1 because it has no resources.
I0823 03:04:00.069504       1 handler.go:288] Adding GroupVersion networking.k8s.io v1 to ResourceManager
W0823 03:04:00.069861       1 genericapiserver.go:778] Skipping API networking.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.069932       1 genericapiserver.go:778] Skipping API networking.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.070369       1 handler.go:288] Adding GroupVersion node.k8s.io v1 to ResourceManager
W0823 03:04:00.070623       1 genericapiserver.go:778] Skipping API node.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.070685       1 genericapiserver.go:778] Skipping API node.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.071215       1 handler.go:288] Adding GroupVersion policy v1 to ResourceManager
W0823 03:04:00.071272       1 genericapiserver.go:778] Skipping API policy/v1beta1 because it has no resources.
I0823 03:04:00.072234       1 handler.go:288] Adding GroupVersion rbac.authorization.k8s.io v1 to ResourceManager
W0823 03:04:00.072352       1 genericapiserver.go:778] Skipping API rbac.authorization.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.072419       1 genericapiserver.go:778] Skipping API rbac.authorization.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.072836       1 handler.go:288] Adding GroupVersion scheduling.k8s.io v1 to ResourceManager
W0823 03:04:00.072913       1 genericapiserver.go:778] Skipping API scheduling.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.072971       1 genericapiserver.go:778] Skipping API scheduling.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.074465       1 handler.go:288] Adding GroupVersion storage.k8s.io v1 to ResourceManager
W0823 03:04:00.074608       1 genericapiserver.go:778] Skipping API storage.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.074688       1 genericapiserver.go:778] Skipping API storage.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.075725       1 handler.go:288] Adding GroupVersion flowcontrol.apiserver.k8s.io v1 to ResourceManager
W0823 03:04:00.075859       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta3 because it has no resources.
W0823 03:04:00.075927       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta2 because it has no resources.
W0823 03:04:00.075988       1 genericapiserver.go:778] Skipping API flowcontrol.apiserver.k8s.io/v1beta1 because it has no resources.
I0823 03:04:00.078606       1 handler.go:288] Adding GroupVersion apps v1 to ResourceManager
W0823 03:04:00.078748       1 genericapiserver.go:778] Skipping API apps/v1beta2 because it has no resources.
W0823 03:04:00.078789       1 genericapiserver.go:778] Skipping API apps/v1beta1 because it has no resources.
I0823 03:04:00.080172       1 handler.go:288] Adding GroupVersion admissionregistration.k8s.io v1 to ResourceManager
W0823 03:04:00.080345       1 genericapiserver.go:778] Skipping API admissionregistration.k8s.io/v1beta1 because it has no resources.
W0823 03:04:00.080413       1 genericapiserver.go:778] Skipping API admissionregistration.k8s.io/v1alpha1 because it has no resources.
I0823 03:04:00.080820       1 handler.go:288] Adding GroupVersion events.k8s.io v1 to ResourceManager
W0823 03:04:00.080887       1 genericapiserver.go:778] Skipping API events.k8s.io/v1beta1 because it has no resources.
I0823 03:04:00.088565       1 handler.go:288] Adding GroupVersion apiregistration.k8s.io v1 to ResourceManager
W0823 03:04:00.088707       1 genericapiserver.go:778] Skipping API apiregistration.k8s.io/v1beta1 because it has no resources.
I0823 03:04:00.557944       1 secure_serving.go:211] Serving securely on [::]:6443
I0823 03:04:00.558551       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/pki/front-proxy-ca.crt"
I0823 03:04:00.558649       1 dynamic_serving_content.go:135] "Starting controller" name="serving-cert::/etc/kubernetes/pki/apiserver.crt::/etc/kubernetes/pki/apiserver.key"
I0823 03:04:00.558692       1 tlsconfig.go:243] "Starting DynamicServingCertificateController"
I0823 03:04:00.562523       1 gc_controller.go:78] Starting apiserver lease garbage collector
I0823 03:04:00.563047       1 controller.go:119] Starting legacy_token_tracking_controller
I0823 03:04:00.563230       1 shared_informer.go:350] "Waiting for caches to sync" controller="configmaps"
I0823 03:04:00.563578       1 controller.go:80] Starting OpenAPI V3 AggregationController
I0823 03:04:00.564369       1 apf_controller.go:377] Starting API Priority and Fairness config controller
I0823 03:04:00.564469       1 system_namespaces_controller.go:66] Starting system namespaces controller
I0823 03:04:00.564601       1 cluster_authentication_trust_controller.go:459] Starting cluster_authentication_trust_controller controller
I0823 03:04:00.564649       1 shared_informer.go:350] "Waiting for caches to sync" controller="cluster_authentication_trust_controller"
I0823 03:04:00.564950       1 customresource_discovery_controller.go:294] Starting DiscoveryController
I0823 03:04:00.564978       1 dynamic_serving_content.go:135] "Starting controller" name="aggregator-proxy-cert::/etc/kubernetes/pki/front-proxy-client.crt::/etc/kubernetes/pki/front-proxy-client.key"
I0823 03:04:00.565022       1 local_available_controller.go:156] Starting LocalAvailability controller
I0823 03:04:00.565026       1 cache.go:32] Waiting for caches to sync for LocalAvailability controller
I0823 03:04:00.565039       1 remote_available_controller.go:411] Starting RemoteAvailability controller
I0823 03:04:00.565042       1 cache.go:32] Waiting for caches to sync for RemoteAvailability controller
I0823 03:04:00.565049       1 apiservice_controller.go:100] Starting APIServiceRegistrationController
I0823 03:04:00.565052       1 cache.go:32] Waiting for caches to sync for APIServiceRegistrationController controller
I0823 03:04:00.565060       1 aggregator.go:169] waiting for initial CRD sync...
I0823 03:04:00.565066       1 controller.go:78] Starting OpenAPI AggregationController
I0823 03:04:00.565085       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
I0823 03:04:00.580141       1 default_servicecidr_controller.go:110] Starting kubernetes-service-cidr-controller
I0823 03:04:00.581046       1 shared_informer.go:350] "Waiting for caches to sync" controller="kubernetes-service-cidr-controller"
I0823 03:04:00.581129       1 repairip.go:200] Starting ipallocator-repair-controller
I0823 03:04:00.581196       1 shared_informer.go:350] "Waiting for caches to sync" controller="ipallocator-repair-controller"
I0823 03:04:00.581471       1 dynamic_cafile_content.go:161] "Starting controller" name="client-ca-bundle::/etc/kubernetes/pki/ca.crt"
I0823 03:04:00.581517       1 dynamic_cafile_content.go:161] "Starting controller" name="request-header::/etc/kubernetes/pki/front-proxy-ca.crt"
I0823 03:04:00.581727       1 controller.go:142] Starting OpenAPI controller
I0823 03:04:00.581743       1 controller.go:90] Starting OpenAPI V3 controller
I0823 03:04:00.581751       1 naming_controller.go:299] Starting NamingConditionController
I0823 03:04:00.581760       1 establishing_controller.go:81] Starting EstablishingController
I0823 03:04:00.581767       1 nonstructuralschema_controller.go:195] Starting NonStructuralSchemaConditionController
I0823 03:04:00.581772       1 apiapproval_controller.go:189] Starting KubernetesAPIApprovalPolicyConformantConditionController
I0823 03:04:00.581781       1 crd_finalizer.go:269] Starting CRDFinalizer
I0823 03:04:00.581962       1 crdregistration_controller.go:114] Starting crd-autoregister controller
I0823 03:04:00.581966       1 shared_informer.go:350] "Waiting for caches to sync" controller="crd-autoregister"
I0823 03:04:00.734945       1 shared_informer.go:357] "Caches are synced" controller="*generic.policySource[*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicy,*k8s.io/api/admissionregistration/v1.ValidatingAdmissionPolicyBinding,k8s.io/apiserver/pkg/admission/plugin/policy/validating.Validator]"
I0823 03:04:00.735136       1 policy_source.go:240] refreshing policies
I0823 03:04:00.735227       1 shared_informer.go:357] "Caches are synced" controller="node_authorizer"
I0823 03:04:00.763372       1 shared_informer.go:357] "Caches are synced" controller="configmaps"
I0823 03:04:00.764706       1 shared_informer.go:357] "Caches are synced" controller="cluster_authentication_trust_controller"
I0823 03:04:00.764934       1 apf_controller.go:382] Running API Priority and Fairness config worker
I0823 03:04:00.764994       1 apf_controller.go:385] Running API Priority and Fairness periodic rebalancing process
I0823 03:04:00.765088       1 handler.go:288] Adding GroupVersion crd.projectcalico.org v1 to ResourceManager
I0823 03:04:00.765726       1 cache.go:39] Caches are synced for APIServiceRegistrationController controller
I0823 03:04:00.769365       1 cache.go:39] Caches are synced for LocalAvailability controller
I0823 03:04:00.769662       1 cache.go:39] Caches are synced for RemoteAvailability controller
I0823 03:04:00.769886       1 handler_discovery.go:451] Starting ResourceDiscoveryManager
I0823 03:04:00.782012       1 shared_informer.go:357] "Caches are synced" controller="crd-autoregister"
I0823 03:04:00.782252       1 shared_informer.go:357] "Caches are synced" controller="kubernetes-service-cidr-controller"
I0823 03:04:00.782335       1 default_servicecidr_controller.go:136] Shutting down kubernetes-service-cidr-controller
I0823 03:04:00.798573       1 shared_informer.go:357] "Caches are synced" controller="ipallocator-repair-controller"
I0823 03:04:00.814619       1 aggregator.go:171] initial CRD sync complete...
I0823 03:04:00.814773       1 autoregister_controller.go:144] Starting autoregister controller
I0823 03:04:00.814818       1 cache.go:32] Waiting for caches to sync for autoregister controller
I0823 03:04:00.814859       1 cache.go:39] Caches are synced for autoregister controller
I0823 03:04:00.834584       1 controller.go:667] quota admission added evaluator for: leases.coordination.k8s.io
I0823 03:04:00.835202       1 cidrallocator.go:301] created ClusterIP allocator for Service CIDR 10.96.0.0/12
I0823 03:04:01.573768       1 storage_scheduling.go:111] all system priority classes are created successfully or already exist.
W0823 03:04:01.778597       1 lease.go:265] Resetting endpoints for master service "kubernetes" to [172.30.1.2]
I0823 03:04:01.779755       1 controller.go:667] quota admission added evaluator for: endpoints
I0823 03:04:01.786033       1 controller.go:667] quota admission added evaluator for: endpointslices.discovery.k8s.io
I0823 03:04:18.827756       1 controller.go:667] quota admission added evaluator for: serviceaccounts
I0823 03:04:20.180680       1 cidrallocator.go:277] updated ClusterIP allocator for Service CIDR 10.96.0.0/12
I0823 03:04:20.347470       1 controller.go:667] quota admission added evaluator for: replicasets.apps
I0823 03:04:20.442935       1 controller.go:667] quota admission added evaluator for: deployments.apps
I0823 03:04:20.543136       1 controller.go:667] quota admission added evaluator for: poddisruptionbudgets.policy
controlplane:/etc/kubernetes/manifests$ k -n kube-system get pod
NAME                                      READY   STATUS    RESTARTS        AGE
calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   9 (7m52s ago)   3d18h
canal-rtfc5                               2/2     Running   2 (4h1m ago)    3d18h
coredns-6ff97d97f9-2rxsf                  1/1     Running   1 (4h1m ago)    3d18h
coredns-6ff97d97f9-85m5c                  1/1     Running   1 (4h1m ago)    3d18h
etcd-controlplane                         1/1     Running   1 (4h1m ago)    3d18h
kube-apiserver-controlplane               1/1     Running   0               8m2s
kube-controller-manager-controlplane      1/1     Running   3 (8m43s ago)   3d18h
kube-proxy-7kdz8                          1/1     Running   1 (4h1m ago)    3d18h
kube-scheduler-controlplane               1/1     Running   3 (8m44s ago)   3d18h
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ ls    
etcd.yaml  kube-apiserver.yaml  kube-apiserver.yaml.ori  kube-controller-manager.yaml  kube-scheduler.yaml
controlplane:/etc/kubernetes/manifests$ vi kube-apiserver.yaml
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ vi kube-apiserver.yaml
controlplane:/etc/kubernetes/manifests$ kubectl get pods -a
error: unknown shorthand flag: 'a' in -a
See 'kubectl get --help' for usage.
controlplane:/etc/kubernetes/manifests$ kubectl get pods -A
The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?
controlplane:/etc/kubernetes/manifests$ cp kube-apiserver.yaml.ori kube-apiserver.yaml
controlplane:/etc/kubernetes/manifests$ kubectl get pods
The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?
controlplane:/etc/kubernetes/manifests$ watch crictl
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ kubectl get pods
The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?
controlplane:/etc/kubernetes/manifests$ kubectl get pods
The connection to the server 172.30.1.2:6443 was refused - did you specify the right host or port?
controlplane:/etc/kubernetes/manifests$ watch crictl ps
controlplane:/etc/kubernetes/manifests$ kubectl get pods
NAME                     READY   STATUS    RESTARTS   AGE
nginx-5869d7778c-fpdjw   1/1     Running   0          5m5s
controlplane:/etc/kubernetes/manifests$ 






