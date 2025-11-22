https://killercoda.com/sachin/course/CKA/ds-issue


controlplane:~$ k get po
NAME                    READY   STATUS              RESTARTS   AGE
cache-daemonset-mlj54   0/1     ContainerCreating   0          10s
controlplane:~$ k get po -w
NAME                    READY   STATUS    RESTARTS   AGE
cache-daemonset-mlj54   1/1     Running   0          13s
^Ccontrolplane:~$ k get po -o wide
NAME                    READY   STATUS    RESTARTS   AGE   IP            NODE     NOMINATED NODE   READINESS GATES
cache-daemonset-mlj54   1/1     Running   0          21s   192.168.1.4   node01   <none>           <none>
controlplane:~$ k get ds -o yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: DaemonSet
  metadata:
    annotations:
      deprecated.daemonset.template.generation: "1"
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"apps/v1","kind":"DaemonSet","metadata":{"annotations":{},"name":"cache-daemonset","namespace":"default"},"spec":{"selector":{"matchLabels":{"app":"cache"}},"template":{"metadata":{"labels":{"app":"cache"}},"spec":{"containers":[{"image":"redis:latest","name":"cache-container","resources":{"limits":{"cpu":"10m","memory":"100Mi"},"requests":{"cpu":"5m","memory":"50Mi"}}}]}}}}
    creationTimestamp: "2025-09-07T10:25:42Z"
    generation: 1
    name: cache-daemonset
    namespace: default
    resourceVersion: "3280"
    uid: fec72ae3-0bfe-4cd4-b9da-9cbc282b6704
  spec:
    revisionHistoryLimit: 10
    selector:
      matchLabels:
        app: cache
    template:
      metadata:
        creationTimestamp: null
        labels:
          app: cache
      spec:
        containers:
        - image: redis:latest
          imagePullPolicy: Always
          name: cache-container
          resources:
            limits:
              cpu: 10m
              memory: 100Mi
            requests:
              cpu: 5m
              memory: 50Mi
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
    updateStrategy:
      rollingUpdate:
        maxSurge: 0
        maxUnavailable: 1
      type: RollingUpdate
  status:
    currentNumberScheduled: 1
    desiredNumberScheduled: 1
    numberAvailable: 1
    numberMisscheduled: 0
    numberReady: 1
    observedGeneration: 1
    updatedNumberScheduled: 1
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get no -o yaml 
apiVersion: v1
items:
- apiVersion: v1
  kind: Node
  metadata:
    annotations:
      flannel.alpha.coreos.com/backend-data: '{"VNI":1,"VtepMAC":"76:a6:b2:1e:9b:b6"}'
      flannel.alpha.coreos.com/backend-type: vxlan
      flannel.alpha.coreos.com/kube-subnet-manager: "true"
      flannel.alpha.coreos.com/public-ip: 172.30.1.2
      kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
      node.alpha.kubernetes.io/ttl: "0"
      projectcalico.org/IPv4Address: 172.30.1.2/24
      projectcalico.org/IPv4IPIPTunnelAddr: 192.168.0.1
      volumes.kubernetes.io/controller-managed-attach-detach: "true"
    creationTimestamp: "2025-08-19T09:03:52Z"
    labels:
      beta.kubernetes.io/arch: amd64
      beta.kubernetes.io/os: linux
      kubernetes.io/arch: amd64
      kubernetes.io/hostname: controlplane
      kubernetes.io/os: linux
      node-role.kubernetes.io/control-plane: ""
      node.kubernetes.io/exclude-from-external-load-balancers: ""
    name: controlplane
    resourceVersion: "3190"
    uid: fa72abf6-d70b-4fcf-976d-5c874b24ef4d
  spec:
    podCIDR: 192.168.0.0/24
    podCIDRs:
    - 192.168.0.0/24
    taints:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
  status:
    addresses:
    - address: 172.30.1.2
      type: InternalIP
    - address: controlplane
      type: Hostname
    allocatable:
      cpu: "1"
      ephemeral-storage: "18698430040"
      hugepages-2Mi: "0"
      memory: 2163840Ki
      pods: "110"
    capacity:
      cpu: "1"
      ephemeral-storage: 19221248Ki
      hugepages-2Mi: "0"
      memory: 2266240Ki
      pods: "110"
    conditions:
    - lastHeartbeatTime: "2025-09-07T10:20:46Z"
      lastTransitionTime: "2025-09-07T10:20:46Z"
      message: Flannel is running on this node
      reason: FlannelIsUp
      status: "False"
      type: NetworkUnavailable
    - lastHeartbeatTime: "2025-09-07T10:25:01Z"
      lastTransitionTime: "2025-08-19T09:03:51Z"
      message: kubelet has sufficient memory available
      reason: KubeletHasSufficientMemory
      status: "False"
      type: MemoryPressure
    - lastHeartbeatTime: "2025-09-07T10:25:01Z"
      lastTransitionTime: "2025-08-19T09:03:51Z"
      message: kubelet has no disk pressure
      reason: KubeletHasNoDiskPressure
      status: "False"
      type: DiskPressure
    - lastHeartbeatTime: "2025-09-07T10:25:01Z"
      lastTransitionTime: "2025-08-19T09:03:51Z"
      message: kubelet has sufficient PID available
      reason: KubeletHasSufficientPID
      status: "False"
      type: PIDPressure
    - lastHeartbeatTime: "2025-09-07T10:25:01Z"
      lastTransitionTime: "2025-08-19T09:03:52Z"
      message: kubelet is posting ready status
      reason: KubeletReady
      status: "True"
      type: Ready
    daemonEndpoints:
      kubeletEndpoint:
        Port: 10250
    images:
    - names:
      - docker.io/calico/cni@sha256:e60b90d7861e872efa720ead575008bc6eca7bee41656735dcaa8210b688fcd9
      - docker.io/calico/cni:v3.24.1
      sizeBytes: 87382462
    - names:
      - docker.io/calico/node@sha256:43f6cee5ca002505ea142b3821a76d585aa0c8d22bc58b7e48589ca7deb48c13
      - docker.io/calico/node:v3.24.1
      sizeBytes: 80180860
    - names:
      - registry.k8s.io/etcd@sha256:d58c035df557080a27387d687092e3fc2b64c6d0e3162dc51453a115f847d121
      - registry.k8s.io/etcd:3.5.21-0
      sizeBytes: 58938593
    - names:
      - registry.k8s.io/kube-proxy@sha256:4796ef3e43efa5ed2a5b015c18f81d3c2fe3aea36f555ea643cc01827eb65e51
      - registry.k8s.io/kube-proxy:v1.33.2
      sizeBytes: 31891765
    - names:
      - docker.io/calico/kube-controllers@sha256:4010b2739792ae5e77a750be909939c0a0a372e378f3c81020754efcf4a91efa
      - docker.io/calico/kube-controllers:v3.24.1
      sizeBytes: 31125927
    - names:
      - registry.k8s.io/kube-apiserver@sha256:e8ae58675899e946fabe38425f2b3bfd33120b7930d05b5898de97c81a7f6137
      - registry.k8s.io/kube-apiserver:v1.33.2
      sizeBytes: 30075899
    - names:
      - registry.k8s.io/kube-controller-manager@sha256:2236e72a4be5dcc9c04600353ff8849db1557f5364947c520ff05471ae719081
      - registry.k8s.io/kube-controller-manager:v1.33.2
      sizeBytes: 27646507
    - names:
      - registry.k8s.io/kube-scheduler@sha256:304c28303133be7d927973bc9bd6c83945b3735c59d283c25b63d5b9ed53bca3
      - registry.k8s.io/kube-scheduler:v1.33.2
      sizeBytes: 21782634
    - names:
      - quay.io/coreos/flannel@sha256:9a296fbb67790659adc3701e287adde3c59803b7fcefe354f1fc482840cdb3d9
      - quay.io/coreos/flannel:v0.15.1
      sizeBytes: 21673107
    - names:
      - docker.io/rancher/local-path-provisioner@sha256:b6625eed863fe77d520f2bf43ef6fa3e2c9db8b52cd114b7d69345d4de5e5bab
      - docker.io/rancher/local-path-provisioner:master-head
      sizeBytes: 21145301
    - names:
      - registry.k8s.io/coredns/coredns@sha256:40384aa1f5ea6bfdc77997d243aec73da05f27aed0c5e9d65bfa98933c519d97
      - registry.k8s.io/coredns/coredns:v1.12.0
      sizeBytes: 20939036
    - names:
      - registry.k8s.io/pause@sha256:ee6521f290b2168b6e0935a181d4cff9be1ac3f505666ef0e3c98fae8199917a
      - registry.k8s.io/pause:3.10
      sizeBytes: 320368
    - names:
      - registry.k8s.io/pause@sha256:1ff6c18fbef2045af6b9c16bf034cc421a29027b800e4f9b68ae9b1cb3e9ae07
      - registry.k8s.io/pause:3.5
      sizeBytes: 301416
    nodeInfo:
      architecture: amd64
      bootID: ae972f28-abb0-46db-aeb7-27efb3a996ab
      containerRuntimeVersion: containerd://1.7.27
      kernelVersion: 6.8.0-51-generic
      kubeProxyVersion: ""
      kubeletVersion: v1.33.2
      machineID: 46cfa4387e104e0a9a886bb62aff2847
      operatingSystem: linux
      osImage: Ubuntu 24.04.1 LTS
      systemUUID: d96df73f-2439-4a40-84b8-92674402dfa2
- apiVersion: v1
  kind: Node
  metadata:
    annotations:
      flannel.alpha.coreos.com/backend-data: '{"VNI":1,"VtepMAC":"d6:30:5c:03:38:4d"}'
      flannel.alpha.coreos.com/backend-type: vxlan
      flannel.alpha.coreos.com/kube-subnet-manager: "true"
      flannel.alpha.coreos.com/public-ip: 172.30.2.2
      kubeadm.alpha.kubernetes.io/cri-socket: unix:///var/run/containerd/containerd.sock
      node.alpha.kubernetes.io/ttl: "0"
      projectcalico.org/IPv4Address: 172.30.2.2/24
      projectcalico.org/IPv4IPIPTunnelAddr: 192.168.1.1
      volumes.kubernetes.io/controller-managed-attach-detach: "true"
    creationTimestamp: "2025-08-19T09:32:03Z"
    labels:
      beta.kubernetes.io/arch: amd64
      beta.kubernetes.io/os: linux
      kubernetes.io/arch: amd64
      kubernetes.io/hostname: node01
      kubernetes.io/os: linux
    name: node01
    resourceVersion: "3313"
    uid: d695cd3c-67a1-4a88-840b-6cab651d5b5d
  spec:
    podCIDR: 192.168.1.0/24
    podCIDRs:
    - 192.168.1.0/24
  status:
    addresses:
    - address: 172.30.2.2
      type: InternalIP
    - address: node01
      type: Hostname
    allocatable:
      cpu: "1"
      ephemeral-storage: "18698430040"
      hugepages-2Mi: "0"
      memory: 1912960Ki
      pods: "110"
    capacity:
      cpu: "1"
      ephemeral-storage: 19221248Ki
      hugepages-2Mi: "0"
      memory: 2015360Ki
      pods: "110"
    conditions:
    - lastHeartbeatTime: "2025-09-07T10:20:51Z"
      lastTransitionTime: "2025-09-07T10:20:51Z"
      message: Flannel is running on this node
      reason: FlannelIsUp
      status: "False"
      type: NetworkUnavailable
    - lastHeartbeatTime: "2025-09-07T10:26:17Z"
      lastTransitionTime: "2025-08-19T09:32:03Z"
      message: kubelet has sufficient memory available
      reason: KubeletHasSufficientMemory
      status: "False"
      type: MemoryPressure
    - lastHeartbeatTime: "2025-09-07T10:26:17Z"
      lastTransitionTime: "2025-08-19T09:32:03Z"
      message: kubelet has no disk pressure
      reason: KubeletHasNoDiskPressure
      status: "False"
      type: DiskPressure
    - lastHeartbeatTime: "2025-09-07T10:26:17Z"
      lastTransitionTime: "2025-08-19T09:32:03Z"
      message: kubelet has sufficient PID available
      reason: KubeletHasSufficientPID
      status: "False"
      type: PIDPressure
    - lastHeartbeatTime: "2025-09-07T10:26:17Z"
      lastTransitionTime: "2025-08-19T09:32:04Z"
      message: kubelet is posting ready status
      reason: KubeletReady
      status: "True"
      type: Ready
    daemonEndpoints:
      kubeletEndpoint:
        Port: 10250
    images:
    - names:
      - docker.io/calico/cni@sha256:e60b90d7861e872efa720ead575008bc6eca7bee41656735dcaa8210b688fcd9
      - docker.io/calico/cni:v3.24.1
      sizeBytes: 87382462
    - names:
      - docker.io/calico/node@sha256:43f6cee5ca002505ea142b3821a76d585aa0c8d22bc58b7e48589ca7deb48c13
      - docker.io/calico/node:v3.24.1
      sizeBytes: 80180860
    - names:
      - docker.io/library/redis@sha256:cc2dfb8f5151da2684b4a09bd04b567f92d07591d91980eb3eca21df07e12760
      - docker.io/library/redis:latest
      sizeBytes: 52441066
    - names:
      - registry.k8s.io/kube-proxy@sha256:4796ef3e43efa5ed2a5b015c18f81d3c2fe3aea36f555ea643cc01827eb65e51
      - registry.k8s.io/kube-proxy:v1.33.2
      sizeBytes: 31891765
    - names:
      - quay.io/coreos/flannel@sha256:9a296fbb67790659adc3701e287adde3c59803b7fcefe354f1fc482840cdb3d9
      - quay.io/coreos/flannel:v0.15.1
      sizeBytes: 21673107
    - names:
      - registry.k8s.io/coredns/coredns@sha256:40384aa1f5ea6bfdc77997d243aec73da05f27aed0c5e9d65bfa98933c519d97
      - registry.k8s.io/coredns/coredns:v1.12.0
      sizeBytes: 20939036
    - names:
      - registry.k8s.io/pause@sha256:1ff6c18fbef2045af6b9c16bf034cc421a29027b800e4f9b68ae9b1cb3e9ae07
      - registry.k8s.io/pause:3.5
      sizeBytes: 301416
    nodeInfo:
      architecture: amd64
      bootID: de95e587-76d0-4c87-9bc4-f1d17a4ce3b8
      containerRuntimeVersion: containerd://1.7.27
      kernelVersion: 6.8.0-51-generic
      kubeProxyVersion: ""
      kubeletVersion: v1.33.2
      machineID: 46cfa4387e104e0a9a886bb62aff2847
      operatingSystem: linux
      osImage: Ubuntu 24.04.1 LTS
      systemUUID: 46718d4e-bc6c-451e-82d0-9725550c058e
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get no -o yaml  | grep -i taints
    taints:
controlplane:~$ k get no -o yaml  | grep -A10 -B10 -i taints
      kubernetes.io/os: linux
      node-role.kubernetes.io/control-plane: ""
      node.kubernetes.io/exclude-from-external-load-balancers: ""
    name: controlplane
    resourceVersion: "3190"
    uid: fa72abf6-d70b-4fcf-976d-5c874b24ef4d
  spec:
    podCIDR: 192.168.0.0/24
    podCIDRs:
    - 192.168.0.0/24
    taints:
    - effect: NoSchedule
      key: node-role.kubernetes.io/control-plane
  status:
    addresses:
    - address: 172.30.1.2
      type: InternalIP
    - address: controlplane
      type: Hostname
    allocatable:
      cpu: "1"
controlplane:~$ ^C
controlplane:~$ k edit ds
daemonset.apps/cache-daemonset edited
controlplane:~$ k get po -w
NAME                    READY   STATUS              RESTARTS   AGE
cache-daemonset-mlj54   1/1     Running             0          2m42s
cache-daemonset-xzscg   0/1     ContainerCreating   0          3s
cache-daemonset-xzscg   1/1     Running             0          13s
cache-daemonset-mlj54   1/1     Terminating         0          2m52s
cache-daemonset-mlj54   1/1     Terminating         0          2m53s
cache-daemonset-mlj54   0/1     Completed           0          2m53s
cache-daemonset-xmp89   0/1     Pending             0          0s
cache-daemonset-xmp89   0/1     Pending             0          0s
cache-daemonset-xmp89   0/1     ContainerCreating   0          0s
cache-daemonset-xmp89   0/1     ContainerCreating   0          0s
cache-daemonset-mlj54   0/1     Completed           0          2m53s
cache-daemonset-mlj54   0/1     Completed           0          2m53s
cache-daemonset-xmp89   1/1     Running             0          4s
^Ccontrolplane:~$ k get po
NAME                    READY   STATUS    RESTARTS   AGE
cache-daemonset-xmp89   1/1     Running   0          21s
cache-daemonset-xzscg   1/1     Running   0          35s
controlplane:~$ 