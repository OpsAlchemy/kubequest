https://killercoda.com/sachin/course/CKA/controller-manager-issue

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k scale deployment 
--replicas  (The new desired number of replicas. Required.)
video-app
controlplane:~$ k scale deployment 
--replicas  (The new desired number of replicas. Required.)
video-app
controlplane:~$ k scale deployment 
--replicas  (The new desired number of replicas. Required.)
video-app
controlplane:~$ k scale deployment video-app --replicas=2
deployment.apps/video-app scaled
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k get po -w
^Ccontrolplane:~$ k get deploy
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
video-app   0/2     0            0           56s
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k describe deployments.apps video-app 
Name:                   video-app
Namespace:              default
CreationTimestamp:      Sun, 07 Sep 2025 09:10:43 +0000
Labels:                 app=video-app
Annotations:            <none>
Selector:               app=video-app
Replicas:               2 desired | 0 updated | 0 total | 0 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=video-app
  Containers:
   redis:
    Image:         redis:7.2.1
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:            <none>
controlplane:~$ k get deployments.apps video-app -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: "2025-09-07T09:10:43Z"
  generation: 1
  labels:
    app: video-app
  name: video-app
  namespace: default
  resourceVersion: "3277"
  uid: aca6f116-bc0c-449f-b512-be9823ab49f7
spec:
  progressDeadlineSeconds: 600
  replicas: 2
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: video-app
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: video-app
    spec:
      containers:
      - image: redis:7.2.1
        imagePullPolicy: IfNotPresent
        name: redis
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status: {}
controlplane:~$ k rollout restart deployment video-app 
deployment.apps/video-app restarted
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k get po -w
^Ccontrolplane:~$ k get deployments.apps 
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
video-app   0/2     0            0           2m12s
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ ^C      
controlplane:~$ k get po -A
NAMESPACE            NAME                                      READY   STATUS             RESTARTS      AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running            2 (10m ago)   19d
kube-system          canal-5q8x5                               2/2     Running            2 (10m ago)   18d
kube-system          canal-hvvtk                               2/2     Running            2 (10m ago)   18d
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running            1 (10m ago)   18d
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running            1 (10m ago)   18d
kube-system          etcd-controlplane                         1/1     Running            2 (10m ago)   19d
kube-system          kube-apiserver-controlplane               1/1     Running            2 (10m ago)   19d
kube-system          kube-controller-manager-controlplane      0/1     CrashLoopBackOff   5 (87s ago)   4m33s
kube-system          kube-proxy-7kdz8                          1/1     Running            2 (10m ago)   19d
kube-system          kube-proxy-lg8cx                          1/1     Running            1 (10m ago)   18d
kube-system          kube-scheduler-controlplane               1/1     Running            2 (10m ago)   19d
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running            2 (10m ago)   19d
controlplane:~$ crictl ps
CONTAINER           IMAGE               CREATED             STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
f3680f865c0c7       3461b62f768ea       9 minutes ago       Running             local-path-provisioner    2                   fc66143a9e162       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
37ef4c4a72ef5       f9c3c1813269c       9 minutes ago       Running             calico-kube-controllers   2                   7c5f7c46b4ce2       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
800ef7e1ccfac       e6ea68648f0cd       10 minutes ago      Running             kube-flannel              1                   da39324af6874       canal-5q8x5                               kube-system
8b97c81704785       75392e3500e36       10 minutes ago      Running             calico-node               1                   da39324af6874       canal-5q8x5                               kube-system
d3305bb7e487d       661d404f36f01       10 minutes ago      Running             kube-proxy                2                   a8176b95b2302       kube-proxy-7kdz8                          kube-system
d0e5aeddb4e43       499038711c081       10 minutes ago      Running             etcd                      2                   a352c10609849       etcd-controlplane                         kube-system
d39f52958ee59       cfed1ff748928       10 minutes ago      Running             kube-scheduler            2                   0a2c42ae359ef       kube-scheduler-controlplane               kube-system
ca5007bbc03b5       ee794efa53d85       10 minutes ago      Running             kube-apiserver            2                   12b34d0912d61       kube-apiserver-controlplane               kube-system
controlplane:~$ crictl ps -a
CONTAINER           IMAGE               CREATED              STATE               NAME                      ATTEMPT             POD ID              POD                                       NAMESPACE
effbc57ec9401       ff4f56c76b82d       About a minute ago   Exited              kube-controller-manager   5                   8c371afd30b44       kube-controller-manager-controlplane      kube-system
f3680f865c0c7       3461b62f768ea       9 minutes ago        Running             local-path-provisioner    2                   fc66143a9e162       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
37ef4c4a72ef5       f9c3c1813269c       9 minutes ago        Running             calico-kube-controllers   2                   7c5f7c46b4ce2       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
800ef7e1ccfac       e6ea68648f0cd       10 minutes ago       Running             kube-flannel              1                   da39324af6874       canal-5q8x5                               kube-system
8b97c81704785       75392e3500e36       10 minutes ago       Running             calico-node               1                   da39324af6874       canal-5q8x5                               kube-system
64aecdd044f60       75392e3500e36       10 minutes ago       Exited              mount-bpffs               0                   da39324af6874       canal-5q8x5                               kube-system
b3299f2e253cd       67fd9ab484510       10 minutes ago       Exited              install-cni               1                   da39324af6874       canal-5q8x5                               kube-system
d3305bb7e487d       661d404f36f01       10 minutes ago       Running             kube-proxy                2                   a8176b95b2302       kube-proxy-7kdz8                          kube-system
d0e5aeddb4e43       499038711c081       10 minutes ago       Running             etcd                      2                   a352c10609849       etcd-controlplane                         kube-system
d39f52958ee59       cfed1ff748928       10 minutes ago       Running             kube-scheduler            2                   0a2c42ae359ef       kube-scheduler-controlplane               kube-system
ca5007bbc03b5       ee794efa53d85       10 minutes ago       Running             kube-apiserver            2                   12b34d0912d61       kube-apiserver-controlplane               kube-system
e7a8d268f3e8b       e6ea68648f0cd       2 weeks ago          Exited              kube-flannel              0                   d55490d67ed11       canal-5q8x5                               kube-system
0885f2419fef8       75392e3500e36       2 weeks ago          Exited              calico-node               0                   d55490d67ed11       canal-5q8x5                               kube-system
c01c18285ab2b       3461b62f768ea       2 weeks ago          Exited              local-path-provisioner    1                   2a72073636b03       local-path-provisioner-5c94487ccb-gmwjg   local-path-storage
82051bf870801       f9c3c1813269c       2 weeks ago          Exited              calico-kube-controllers   1                   40f223ecc53f4       calico-kube-controllers-fdf5f5495-8jbqm   kube-system
ae7f718bc47b0       661d404f36f01       2 weeks ago          Exited              kube-proxy                1                   b822c4febcdf9       kube-proxy-7kdz8                          kube-system
5010714c18dcb       cfed1ff748928       2 weeks ago          Exited              kube-scheduler            1                   8f614d101e53b       kube-scheduler-controlplane               kube-system
656e6645bbcac       499038711c081       2 weeks ago          Exited              etcd                      1                   821997b2d22ad       etcd-controlplane                         kube-system
33596c8724717       ee794efa53d85       2 weeks ago          Exited              kube-apiserver            1                   b2b1fedcf6176       kube-apiserver-controlplane               kube-system
controlplane:~$ ^C
controlplane:~$ crictl logs effbc57ec9401
controlplane:~$ ^C
controlplane:~$ crictl logs effbc57ec9401
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k get po -A
NAMESPACE            NAME                                      READY   STATUS             RESTARTS        AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running            2 (11m ago)     19d
kube-system          canal-5q8x5                               2/2     Running            2 (11m ago)     18d
kube-system          canal-hvvtk                               2/2     Running            2 (11m ago)     18d
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running            1 (11m ago)     18d
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running            1 (11m ago)     18d
kube-system          etcd-controlplane                         1/1     Running            2 (11m ago)     19d
kube-system          kube-apiserver-controlplane               1/1     Running            2 (11m ago)     19d
kube-system          kube-controller-manager-controlplane      0/1     CrashLoopBackOff   5 (2m25s ago)   5m31s
kube-system          kube-proxy-7kdz8                          1/1     Running            2 (11m ago)     19d
kube-system          kube-proxy-lg8cx                          1/1     Running            1 (11m ago)     18d
kube-system          kube-scheduler-controlplane               1/1     Running            2 (11m ago)     19d
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running            2 (11m ago)     19d
controlplane:~$ k -n kube-system describe po kube-controller-manager-controlplane
Name:                 kube-controller-manager-controlplane
Namespace:            kube-system
Priority:             2000001000
Priority Class Name:  system-node-critical
Node:                 controlplane/172.30.1.2
Start Time:           Sun, 07 Sep 2025 09:05:06 +0000
Labels:               component=kube-controller-manager
                      tier=control-plane
Annotations:          kubernetes.io/config.hash: c2086dde319f21250262f5d5edcf3af3
                      kubernetes.io/config.mirror: c2086dde319f21250262f5d5edcf3af3
                      kubernetes.io/config.seen: 2025-09-07T09:10:43.614689821Z
                      kubernetes.io/config.source: file
Status:               Running
SeccompProfile:       RuntimeDefault
IP:                   172.30.1.2
IPs:
  IP:           172.30.1.2
Controlled By:  Node/controlplane
Containers:
  kube-controller-manager:
    Container ID:  containerd://7853f4e751554b816a83070ede84c81843f8bf2af9d0ec2c0da2e221b4ecfdba
    Image:         registry.k8s.io/kube-controller-manager:v1.33.2
    Image ID:      registry.k8s.io/kube-controller-manager@sha256:2236e72a4be5dcc9c04600353ff8849db1557f5364947c520ff05471ae719081
    Port:          <none>
    Host Port:     <none>
    Command:
      kube-controller-manegaar
      --allocate-node-cidrs=true
      --authentication-kubeconfig=/etc/kubernetes/controller-manager.conf
      --authorization-kubeconfig=/etc/kubernetes/controller-manager.conf
      --bind-address=127.0.0.1
      --client-ca-file=/etc/kubernetes/pki/ca.crt
      --cluster-cidr=192.168.0.0/16
      --cluster-name=kubernetes
      --cluster-signing-cert-file=/etc/kubernetes/pki/ca.crt
      --cluster-signing-key-file=/etc/kubernetes/pki/ca.key
      --controllers=*,bootstrapsigner,tokencleaner
      --kubeconfig=/etc/kubernetes/controller-manager.conf
      --leader-elect=true
      --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
      --root-ca-file=/etc/kubernetes/pki/ca.crt
      --service-account-private-key-file=/etc/kubernetes/pki/sa.key
      --service-cluster-ip-range=10.96.0.0/12
      --use-service-account-credentials=true
    State:          Waiting
      Reason:       RunContainerError
    Last State:     Terminated
      Reason:       StartError
      Message:      failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "kube-controller-manegaar": executable file not found in $PATH: unknown
      Exit Code:    128
      Started:      Thu, 01 Jan 1970 00:00:00 +0000
      Finished:     Sun, 07 Sep 2025 09:16:49 +0000
    Ready:          False
    Restart Count:  6
    Requests:
      cpu:        25m
    Liveness:     http-get https://127.0.0.1:10257/healthz delay=10s timeout=15s period=10s #success=1 #failure=8
    Startup:      http-get https://127.0.0.1:10257/healthz delay=10s timeout=15s period=10s #success=1 #failure=24
    Environment:  <none>
    Mounts:
      /etc/ca-certificates from etc-ca-certificates (ro)
      /etc/kubernetes/controller-manager.conf from kubeconfig (ro)
      /etc/kubernetes/pki from k8s-certs (ro)
      /etc/ssl/certs from ca-certs (ro)
      /usr/libexec/kubernetes/kubelet-plugins/volume/exec from flexvolume-dir (rw)
      /usr/local/share/ca-certificates from usr-local-share-ca-certificates (ro)
      /usr/share/ca-certificates from usr-share-ca-certificates (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  ca-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/ssl/certs
    HostPathType:  DirectoryOrCreate
  etc-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/ca-certificates
    HostPathType:  DirectoryOrCreate
  flexvolume-dir:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/libexec/kubernetes/kubelet-plugins/volume/exec
    HostPathType:  DirectoryOrCreate
  k8s-certs:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/pki
    HostPathType:  DirectoryOrCreate
  kubeconfig:
    Type:          HostPath (bare host directory volume)
    Path:          /etc/kubernetes/controller-manager.conf
    HostPathType:  FileOrCreate
  usr-local-share-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/local/share/ca-certificates
    HostPathType:  DirectoryOrCreate
  usr-share-ca-certificates:
    Type:          HostPath (bare host directory volume)
    Path:          /usr/share/ca-certificates
    HostPathType:  DirectoryOrCreate
QoS Class:         Burstable
Node-Selectors:    <none>
Tolerations:       :NoExecute op=Exists
Events:
  Type     Reason   Age                    From     Message
  ----     ------   ----                   ----     -------
  Warning  Failed   4m17s (x5 over 5m54s)  kubelet  Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "kube-controller-manegaar": executable file not found in $PATH: unknown
  Warning  BackOff  50s (x33 over 5m53s)   kubelet  Back-off restarting failed container kube-controller-manager in pod kube-controller-manager-controlplane_kube-system(c2086dde319f21250262f5d5edcf3af3)
  Normal   Pulled   6s (x7 over 5m55s)     kubelet  Container image "registry.k8s.io/kube-controller-manager:v1.33.2" already present on machine
  Normal   Created  6s (x7 over 5m55s)     kubelet  Created container: kube-controller-manager
controlplane:~$ cd /etc/kubernetes/manifests/  
controlplane:/etc/kubernetes/manifests$ ls
etcd.yaml  kube-apiserver.yaml  kube-controller-manager.yaml  kube-scheduler.yaml
controlplane:/etc/kubernetes/manifests$ vi kube-controller-manager.yaml 
controlplane:/etc/kubernetes/manifests$ k get po -A -w
NAMESPACE            NAME                                      READY   STATUS    RESTARTS      AGE
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running   2 (12m ago)   19d
kube-system          canal-5q8x5                               2/2     Running   2 (12m ago)   18d
kube-system          canal-hvvtk                               2/2     Running   2 (12m ago)   18d
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running   1 (12m ago)   18d
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running   1 (12m ago)   18d
kube-system          etcd-controlplane                         1/1     Running   2 (12m ago)   19d
kube-system          kube-apiserver-controlplane               1/1     Running   2 (12m ago)   19d
kube-system          kube-proxy-7kdz8                          1/1     Running   2 (12m ago)   19d
kube-system          kube-proxy-lg8cx                          1/1     Running   1 (12m ago)   18d
kube-system          kube-scheduler-controlplane               1/1     Running   2 (12m ago)   19d
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running   2 (12m ago)   19d
kube-system          kube-controller-manager-controlplane      0/1     Pending   0             0s
kube-system          kube-controller-manager-controlplane      0/1     ContainerCreating   0             0s
kube-system          kube-controller-manager-controlplane      0/1     Running             0             1s
^Ccontrolplane:/etc/kubernetes/manifests$ k get po
No resources found in default namespace.
controlplane:/etc/kubernetes/manifests$ k get po
No resources found in default namespace.
controlplane:/etc/kubernetes/manifests$ k get deployments.apps 
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
video-app   0/2     0            0           7m12s
controlplane:/etc/kubernetes/manifests$ k rollout restart deployment video-app 
deployment.apps/video-app restarted
controlplane:/etc/kubernetes/manifests$ k get po
No resources found in default namespace.
controlplane:/etc/kubernetes/manifests$ k get po -A
NAMESPACE            NAME                                      READY   STATUS              RESTARTS      AGE
default              video-app-5c4fbf48df-gjm9p                0/1     ContainerCreating   0             3s
default              video-app-5c4fbf48df-h5h5l                0/1     ContainerCreating   0             3s
kube-system          calico-kube-controllers-fdf5f5495-8jbqm   1/1     Running             2 (13m ago)   19d
kube-system          canal-5q8x5                               2/2     Running             2 (13m ago)   18d
kube-system          canal-hvvtk                               2/2     Running             2 (13m ago)   18d
kube-system          coredns-6ff97d97f9-gq4nd                  1/1     Running             1 (13m ago)   18d
kube-system          coredns-6ff97d97f9-hcn7j                  1/1     Running             1 (13m ago)   18d
kube-system          etcd-controlplane                         1/1     Running             2 (13m ago)   19d
kube-system          kube-apiserver-controlplane               1/1     Running             2 (13m ago)   19d
kube-system          kube-controller-manager-controlplane      1/1     Running             0             25s
kube-system          kube-proxy-7kdz8                          1/1     Running             2 (13m ago)   19d
kube-system          kube-proxy-lg8cx                          1/1     Running             1 (13m ago)   18d
kube-system          kube-scheduler-controlplane               1/1     Running             2 (13m ago)   19d
local-path-storage   local-path-provisioner-5c94487ccb-gmwjg   1/1     Running             2 (13m ago)   19d
controlplane:/etc/kubernetes/manifests$ k get po
NAME                         READY   STATUS              RESTARTS   AGE
video-app-5c4fbf48df-gjm9p   0/1     ContainerCreating   0          7s
video-app-5c4fbf48df-h5h5l   0/1     ContainerCreating   0          7s
controlplane:/etc/kubernetes/manifests$ 