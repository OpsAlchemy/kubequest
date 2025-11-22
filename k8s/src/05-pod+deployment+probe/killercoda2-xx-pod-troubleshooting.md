controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get deployments.apps nginx-deployment -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"image":"nginx:latest","name":"nginx-container","ports":[{"containerPort":80}]}],"initContainers":[{"command":["shell","echo 'Welcome To KillerCoda!'"],"image":"busybox","name":"init-container","volumeMounts":[{"mountPath":"/etc/nginx/nginx.conf","name":"nginx-config"}]}],"volumes":[{"configMap":{"name":"nginx-configuration"},"name":"nginx-config"}]}}}}
  creationTimestamp: "2025-09-07T02:03:53Z"
  generation: 1
  name: nginx-deployment
  namespace: default
  resourceVersion: "5342"
  uid: 2eb08093-7a59-476a-b4a0-277d2fce1be5
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:latest
        imagePullPolicy: Always
        name: nginx-container
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - shell
        - echo 'Welcome To KillerCoda!'
        image: busybox
        imagePullPolicy: Always
        name: init-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/nginx/nginx.conf
          name: nginx-config
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: nginx-configuration
        name: nginx-config
status:
  conditions:
  - lastTransitionTime: "2025-09-07T02:03:53Z"
    lastUpdateTime: "2025-09-07T02:03:53Z"
    message: Deployment does not have minimum availability.
    reason: MinimumReplicasUnavailable
    status: "False"
    type: Available
  - lastTransitionTime: "2025-09-07T02:03:53Z"
    lastUpdateTime: "2025-09-07T02:03:53Z"
    message: ReplicaSet "nginx-deployment-7df8cc9d85" is progressing.
    reason: ReplicaSetUpdated
    status: "True"
    type: Progressing
  observedGeneration: 1
  replicas: 1
  unavailableReplicas: 1
  updatedReplicas: 1
controlplane:~$ k describe deployments.apps nginx-deployment 
Name:                   nginx-deployment
Namespace:              default
CreationTimestamp:      Sun, 07 Sep 2025 02:03:53 +0000
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=nginx
Replicas:               1 desired | 1 updated | 1 total | 0 available | 1 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=nginx
  Init Containers:
   init-container:
    Image:      busybox
    Port:       <none>
    Host Port:  <none>
    Command:
      shell
      echo 'Welcome To KillerCoda!'
    Environment:  <none>
    Mounts:
      /etc/nginx/nginx.conf from nginx-config (rw)
  Containers:
   nginx-container:
    Image:        nginx:latest
    Port:         80/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:
   nginx-config:
    Type:          ConfigMap (a volume populated by a ConfigMap)
    Name:          nginx-configuration
    Optional:      false
  Node-Selectors:  <none>
  Tolerations:     <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      False   MinimumReplicasUnavailable
  Progressing    True    ReplicaSetUpdated
OldReplicaSets:  <none>
NewReplicaSet:   nginx-deployment-7df8cc9d85 (1/1 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  3m18s  deployment-controller  Scaled up replica set nginx-deployment-7df8cc9d85 from 0 to 1
controlplane:~$ k get po
NAME                                READY   STATUS     RESTARTS   AGE
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1   0          3m24s
controlplane:~$ k run nginx --image nginx --command -- "shell" "echo 'dlfd'"
pod/nginx created
controlplane:~$ k get po
NAME                                READY   STATUS              RESTARTS   AGE
nginx                               0/1     ContainerCreating   0          2s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1            0          4m41s
controlplane:~$ k get po
NAME                                READY   STATUS              RESTARTS   AGE
nginx                               0/1     ContainerCreating   0          5s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1            0          4m44s
controlplane:~$ k get po -w
NAME                                READY   STATUS              RESTARTS   AGE
nginx                               0/1     ContainerCreating   0          8s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1            0          4m47s
nginx                               0/1     RunContainerError   0          9s
nginx                               0/1     RunContainerError   1 (1s ago)   11s
^Ccontrolplane:~$ k describe po nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             node01/172.30.2.2
Start Time:       Sun, 07 Sep 2025 02:08:32 +0000
Labels:           run=nginx
Annotations:      cni.projectcalico.org/containerID: 7e1463c8348e9a69e211fb2936703c5ad2e6a6a11b412ddc1d7d2da38159d90d
                  cni.projectcalico.org/podIP: 192.168.1.4/32
                  cni.projectcalico.org/podIPs: 192.168.1.4/32
Status:           Running
IP:               192.168.1.4
IPs:
  IP:  192.168.1.4
Containers:
  nginx:
    Container ID:  containerd://60e053ca6ea18075715f8050f622509e0cfacf19f9d089103be565e48b7b8ba5
    Image:         nginx
    Image ID:      docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
    Port:          <none>
    Host Port:     <none>
    Command:
      shell
      echo 'dlfd'
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       StartError
      Message:      failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "shell": executable file not found in $PATH: unknown
      Exit Code:    128
      Started:      Thu, 01 Jan 1970 00:00:00 +0000
      Finished:     Sun, 07 Sep 2025 02:08:42 +0000
    Ready:          False
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-c6mhs (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-c6mhs:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  20s                default-scheduler  Successfully assigned default/nginx to node01
  Normal   Pulled     12s                kubelet            Successfully pulled image "nginx" in 7.629s (7.629s including waiting). Image size: 72324501 bytes.
  Normal   Pulling    11s (x2 over 20s)  kubelet            Pulling image "nginx"
  Normal   Created    10s (x2 over 12s)  kubelet            Created container: nginx
  Warning  Failed     10s (x2 over 11s)  kubelet            Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "shell": executable file not found in $PATH: unknown
  Normal   Pulled     10s                kubelet            Successfully pulled image "nginx" in 848ms (848ms including waiting). Image size: 72324501 bytes.
  Warning  BackOff    8s (x2 over 9s)    kubelet            Back-off restarting failed container nginx in pod nginx_default(9a1f237e-abeb-4cdf-81a1-f0f8f4c715f8)
controlplane:~$ k delete po nginx
pod "nginx" deleted
^[[Acontrolplane:~$ k delete po nginx^C
controlplane:~$ k run nginx --image nginx --command -- "shell" "-c" "echo 'dlfd'"
pod/nginx created
controlplane:~$ k get po -w
NAME                                READY   STATUS              RESTARTS     AGE
nginx                               0/1     RunContainerError   1 (0s ago)   3s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1            0            5m37s
nginx                               0/1     CrashLoopBackOff    1 (1s ago)   4s
^Ccontrolplane:~$ ^C
controlplane:~$ k describe po nginx
Name:             nginx
Namespace:        default
Priority:         0
Service Account:  default
Node:             node01/172.30.2.2
Start Time:       Sun, 07 Sep 2025 02:09:27 +0000
Labels:           run=nginx
Annotations:      cni.projectcalico.org/containerID: 25761a44e2e2019bc3b63a2df806b762aa599f40e28499bc8efbafd57cb36c97
                  cni.projectcalico.org/podIP: 192.168.1.5/32
                  cni.projectcalico.org/podIPs: 192.168.1.5/32
Status:           Running
IP:               192.168.1.5
IPs:
  IP:  192.168.1.5
Containers:
  nginx:
    Container ID:  containerd://187c1e27056d81a6564c0402ed03233783efc1a8fb2de8614736679be0bc63a8
    Image:         nginx
    Image ID:      docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
    Port:          <none>
    Host Port:     <none>
    Command:
      shell
      -c
      echo 'dlfd'
    State:          Waiting
      Reason:       CrashLoopBackOff
    Last State:     Terminated
      Reason:       StartError
      Message:      failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "shell": executable file not found in $PATH: unknown
      Exit Code:    128
      Started:      Thu, 01 Jan 1970 00:00:00 +0000
      Finished:     Sun, 07 Sep 2025 02:09:30 +0000
    Ready:          False
    Restart Count:  1
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-k8p22 (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   True 
  Initialized                 True 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  kube-api-access-k8p22:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason     Age                From               Message
  ----     ------     ----               ----               -------
  Normal   Scheduled  16s                default-scheduler  Successfully assigned default/nginx to node01
  Normal   Pulled     15s                kubelet            Successfully pulled image "nginx" in 698ms (698ms including waiting). Image size: 72324501 bytes.
  Normal   Pulling    14s (x2 over 16s)  kubelet            Pulling image "nginx"
  Normal   Created    13s (x2 over 15s)  kubelet            Created container: nginx
  Warning  Failed     13s (x2 over 15s)  kubelet            Error: failed to create containerd task: failed to create shim task: OCI runtime create failed: runc create failed: unable to start container process: error during container init: exec: "shell": executable file not found in $PATH: unknown
  Normal   Pulled     13s                kubelet            Successfully pulled image "nginx" in 702ms (702ms including waiting). Image size: 72324501 bytes.
  Warning  BackOff    12s (x2 over 13s)  kubelet            Back-off restarting failed container nginx in pod nginx_default(156fd380-5b60-4d8b-8a02-f189ab47ddd1)
controlplane:~$ k logs nginx   
controlplane:~$ k get po
NAME                                READY   STATUS              RESTARTS     AGE
nginx                               0/1     RunContainerError   2 (9s ago)   29s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1            0            6m3s
controlplane:~$ k describe po nginx-deployment-7df8cc9d85-x2bqc 
Name:             nginx-deployment-7df8cc9d85-x2bqc
Namespace:        default
Priority:         0
Service Account:  default
Node:             node01/172.30.2.2
Start Time:       Sun, 07 Sep 2025 02:03:53 +0000
Labels:           app=nginx
                  pod-template-hash=7df8cc9d85
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Controlled By:    ReplicaSet/nginx-deployment-7df8cc9d85
Init Containers:
  init-container:
    Container ID:  
    Image:         busybox
    Image ID:      
    Port:          <none>
    Host Port:     <none>
    Command:
      shell
      echo 'Welcome To KillerCoda!'
    State:          Waiting
      Reason:       PodInitializing
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /etc/nginx/nginx.conf from nginx-config (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ftrbd (ro)
Containers:
  nginx-container:
    Container ID:   
    Image:          nginx:latest
    Image ID:       
    Port:           80/TCP
    Host Port:      0/TCP
    State:          Waiting
      Reason:       PodInitializing
    Ready:          False
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-ftrbd (ro)
Conditions:
  Type                        Status
  PodReadyToStartContainers   False 
  Initialized                 False 
  Ready                       False 
  ContainersReady             False 
  PodScheduled                True 
Volumes:
  nginx-config:
    Type:      ConfigMap (a volume populated by a ConfigMap)
    Name:      nginx-configuration
    Optional:  false
  kube-api-access-ftrbd:
    Type:                    Projected (a volume that contains injected data from multiple sources)
    TokenExpirationSeconds:  3607
    ConfigMapName:           kube-root-ca.crt
    Optional:                false
    DownwardAPI:             true
QoS Class:                   BestEffort
Node-Selectors:              <none>
Tolerations:                 node.kubernetes.io/not-ready:NoExecute op=Exists for 300s
                             node.kubernetes.io/unreachable:NoExecute op=Exists for 300s
Events:
  Type     Reason       Age                  From               Message
  ----     ------       ----                 ----               -------
  Normal   Scheduled    6m13s                default-scheduler  Successfully assigned default/nginx-deployment-7df8cc9d85-x2bqc to node01
  Warning  FailedMount  1s (x11 over 6m13s)  kubelet            MountVolume.SetUp failed for volume "nginx-config" : configmap "nginx-configuration" not found
controlplane:~$ k get cm
NAME               DATA   AGE
kube-root-ca.crt   1      18d
nginx-configmap    1      6m24s
controlplane:~$ k edit deployments.apps nginx-deployment 
deployment.apps/nginx-deployment edited
controlplane:~$ k get po -w
NAME                                READY   STATUS             RESTARTS      AGE
nginx                               0/1     CrashLoopBackOff   3 (37s ago)   83s
nginx-deployment-7df8cc9d85-x2bqc   0/1     Init:0/1           0             6m57s
nginx-deployment-854cc5bc79-gz4sd   0/1     Init:0/1           0             3s
nginx-deployment-854cc5bc79-gz4sd   0/1     Init:RunContainerError   0             5s
nginx-deployment-854cc5bc79-gz4sd   0/1     Init:RunContainerError   1 (1s ago)    7s
nginx-deployment-854cc5bc79-gz4sd   0/1     Init:CrashLoopBackOff    1 (2s ago)    8s
nginx                               0/1     RunContainerError        4 (0s ago)    95s
^Ccontrolplane:~$ k edit deployments.apps nginx-deployment 
deployment.apps/nginx-deployment edited
controlplane:~$ k get po
NAME                                READY   STATUS                  RESTARTS      AGE
nginx                               0/1     CrashLoopBackOff        4 (30s ago)   2m5s
nginx-deployment-777d58f4b7-9ccmv   0/1     PodInitializing         0             2s
nginx-deployment-854cc5bc79-gz4sd   0/1     Init:CrashLoopBackOff   2 (22s ago)   45s
controlplane:~$ k get po -w
NAME                                READY   STATUS             RESTARTS      AGE
nginx                               0/1     CrashLoopBackOff   4 (35s ago)   2m10s
nginx-deployment-777d58f4b7-9ccmv   1/1     Running            0             7s
^Ccontrolplane:~$ k get deployments.apps nginx-deployment -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "3"
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"apps/v1","kind":"Deployment","metadata":{"annotations":{},"name":"nginx-deployment","namespace":"default"},"spec":{"replicas":1,"selector":{"matchLabels":{"app":"nginx"}},"template":{"metadata":{"labels":{"app":"nginx"}},"spec":{"containers":[{"image":"nginx:latest","name":"nginx-container","ports":[{"containerPort":80}]}],"initContainers":[{"command":["shell","echo 'Welcome To KillerCoda!'"],"image":"busybox","name":"init-container","volumeMounts":[{"mountPath":"/etc/nginx/nginx.conf","name":"nginx-config"}]}],"volumes":[{"configMap":{"name":"nginx-configuration"},"name":"nginx-config"}]}}}}
  creationTimestamp: "2025-09-07T02:03:53Z"
  generation: 3
  name: nginx-deployment
  namespace: default
  resourceVersion: "6160"
  uid: 2eb08093-7a59-476a-b4a0-277d2fce1be5
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx:latest
        imagePullPolicy: Always
        name: nginx-container
        ports:
        - containerPort: 80
          protocol: TCP
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      initContainers:
      - command:
        - /bin/sh
        - -c
        - echo 'Welcome To KillerCoda!'
        image: busybox
        imagePullPolicy: Always
        name: init-container
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
        volumeMounts:
        - mountPath: /etc/nginx/nginx.conf
          name: nginx-config
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
      volumes:
      - configMap:
          defaultMode: 420
          name: nginx-configmap
        name: nginx-config
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2025-09-07T02:11:34Z"
    lastUpdateTime: "2025-09-07T02:11:34Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2025-09-07T02:03:53Z"
    lastUpdateTime: "2025-09-07T02:11:34Z"
    message: ReplicaSet "nginx-deployment-777d58f4b7" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 3
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
controlplane:~$ 

https://killercoda.com/sachin/course/CKA/deployment-issue-1