https://killercoda.com/sachin/course/CKA/Shared-Volume

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pod my-pod-cka -o yaml > pod.yaml
controlplane:~$ k delete -f pod.yaml
pod "my-pod-cka" deleted
controlplane:~$ vi pod.yaml
controlplane:~$ k get pvc
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc-cka   Bound    pvc-3f7bfa4d-9692-4980-8bc8-efd9e675f064   100Mi      RWO            local-path     <unset>                 3m34s
controlplane:~$ vi pod.yaml
controlplane:~$ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: 1711ebd973183129e352c8937245da094a2fab7d0b27631978bb26dc43218c40
    cni.projectcalico.org/podIP: 192.168.1.5/32
    cni.projectcalico.org/podIPs: 192.168.1.5/32
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"my-pod-cka","namespace":"default"},"spec":{"containers":[{"image":"nginx","name":"nginx-container","volumeMounts":[{"mountPath":"/var/www/html","name":"shared-storage"}]}],"volumes":[{"name":"shared-storage","persistentVolumeClaim":{"claimName":"my-pvc-cka"}}]}}
  creationTimestamp: "2025-09-05T05:30:30Z"
  generation: 1
  name: my-pod-cka
  namespace: default
  resourceVersion: "3120"
  uid: 8aa4ac15-d9c0-44a0-92c6-5fb956e050a8
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx-container
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/www/html
      name: shared-storage
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-zwxsm
      readOnly: true
    - mountPath: /var/www/shared
      name: shared-storage
  - image: busybox
    name: busybox
    command: ["tail", "-f", "/dev/null"]
    volumeMounts:
    - mountPath: /var/www/shared
      name: shared-storage
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node01
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: my-pvc-cka
  - name: kube-api-access-zwxsm
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: PodReadyToStartContainers
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:38Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:38Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://b080c00c7813a42afabfafe6c420045202e160e4865af92d05d2a2403a586ca5
    image: docker.io/library/nginx:latest
    imageID: docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
    lastState: {}
    name: nginx-container
    ready: true
    resources: {}
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2025-09-05T05:30:48Z"
    volumeMounts:
    - mountPath: /var/www/html
      name: shared-storage
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-zwxsm
      readOnly: true
      recursiveReadOnly: Disabled
  hostIP: 172.30.2.2
  hostIPs:
  - ip: 172.30.2.2
  phase: Running
  podIP: 192.168.1.5
  podIPs:
  - ip: 192.168.1.5
  qosClass: BestEffort
  startTime: "2025-09-05T05:30:38Z"
controlplane:~$ k apply -f pod.yaml
pod/my-pod-cka created
controlplane:~$ k get po -w
NAME         READY   STATUS              RESTARTS   AGE
my-pod-cka   0/2     ContainerCreating   0          2s
my-pod-cka   2/2     Running             0          3s
^Ccontrolplane:~$ k get pods
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   2/2     Running   0          8s
controlplane:~$ 


Solution:-
Step 1: run edit pod my-pod-cka command
kubectl edit po my-pod-cka
Step 2: Update sidecontainer and save it
- name: sidecar-container
image: busybox
command: ["sh", "-c", "tail -f /dev/null"]
volumeMounts:
- name: shared-storage
mountPath: /var/www/shared
readOnly: true
Step 3: run kubectl replace command
kubectl replace -f /tmp/kubectl-edit-1047923679.yaml --force


ontrolplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pod my-pod-cka -o yaml > pod.yaml
controlplane:~$ k delete -f pod.yaml
pod "my-pod-cka" deleted
controlplane:~$ vi pod.yaml
controlplane:~$ k get pvc
NAME         STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc-cka   Bound    pvc-3f7bfa4d-9692-4980-8bc8-efd9e675f064   100Mi      RWO            local-path     <unset>                 3m34s
controlplane:~$ vi pod.yaml
controlplane:~$ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: 1711ebd973183129e352c8937245da094a2fab7d0b27631978bb26dc43218c40
    cni.projectcalico.org/podIP: 192.168.1.5/32
    cni.projectcalico.org/podIPs: 192.168.1.5/32
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"my-pod-cka","namespace":"default"},"spec":{"containers":[{"image":"nginx","name":"nginx-container","volumeMounts":[{"mountPath":"/var/www/html","name":"shared-storage"}]}],"volumes":[{"name":"shared-storage","persistentVolumeClaim":{"claimName":"my-pvc-cka"}}]}}
  creationTimestamp: "2025-09-05T05:30:30Z"
  generation: 1
  name: my-pod-cka
  namespace: default
  resourceVersion: "3120"
  uid: 8aa4ac15-d9c0-44a0-92c6-5fb956e050a8
spec:
  containers:
  - image: nginx
    imagePullPolicy: Always
    name: nginx-container
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /var/www/html
      name: shared-storage
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-zwxsm
      readOnly: true
    - mountPath: /var/www/shared
      name: shared-storage
  - image: busybox
    name: busybox
    command: ["tail", "-f", "/dev/null"]
    volumeMounts:
    - mountPath: /var/www/shared
      name: shared-storage
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
  nodeName: node01
  preemptionPolicy: PreemptLowerPriority
  priority: 0
  restartPolicy: Always
  schedulerName: default-scheduler
  securityContext: {}
  serviceAccount: default
  serviceAccountName: default
  terminationGracePeriodSeconds: 30
  tolerations:
  - effect: NoExecute
    key: node.kubernetes.io/not-ready
    operator: Exists
    tolerationSeconds: 300
  - effect: NoExecute
    key: node.kubernetes.io/unreachable
    operator: Exists
    tolerationSeconds: 300
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: my-pvc-cka
  - name: kube-api-access-zwxsm
    projected:
      defaultMode: 420
      sources:
      - serviceAccountToken:
          expirationSeconds: 3607
          path: token
      - configMap:
          items:
          - key: ca.crt
            path: ca.crt
          name: kube-root-ca.crt
      - downwardAPI:
          items:
          - fieldRef:
              apiVersion: v1
              fieldPath: metadata.namespace
            path: namespace
status:
  conditions:
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: PodReadyToStartContainers
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:38Z"
    status: "True"
    type: Initialized
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: Ready
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:48Z"
    status: "True"
    type: ContainersReady
  - lastProbeTime: null
    lastTransitionTime: "2025-09-05T05:30:38Z"
    status: "True"
    type: PodScheduled
  containerStatuses:
  - containerID: containerd://b080c00c7813a42afabfafe6c420045202e160e4865af92d05d2a2403a586ca5
    image: docker.io/library/nginx:latest
    imageID: docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57
    lastState: {}
    name: nginx-container
    ready: true
    resources: {}
    restartCount: 0
    started: true
    state:
      running:
        startedAt: "2025-09-05T05:30:48Z"
    volumeMounts:
    - mountPath: /var/www/html
      name: shared-storage
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-zwxsm
      readOnly: true
      recursiveReadOnly: Disabled
  hostIP: 172.30.2.2
  hostIPs:
  - ip: 172.30.2.2
  phase: Running
  podIP: 192.168.1.5
  podIPs:
  - ip: 192.168.1.5
  qosClass: BestEffort
  startTime: "2025-09-05T05:30:38Z"
controlplane:~$ k apply -f pod.yaml
pod/my-pod-cka created
controlplane:~$ k get po -w
NAME         READY   STATUS              RESTARTS   AGE
my-pod-cka   0/2     ContainerCreating   0          2s
my-pod-cka   2/2     Running             0          3s
^Ccontrolplane:~$ k get pods
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   2/2     Running   0          8s
controlplane:~$ ^C
controlplane:~$ vi pod.yaml
controlplane:~$ k apply -f pod.yaml
Error from server (Conflict): error when applying patch:
{"metadata":{"annotations":{"cni.projectcalico.org/containerID":"1711ebd973183129e352c8937245da094a2fab7d0b27631978bb26dc43218c40","cni.projectcalico.org/podIP":"192.168.1.5/32","cni.projectcalico.org/podIPs":"192.168.1.5/32","kubectl.kubernetes.io/last-applied-configuration":"{\"apiVersion\":\"v1\",\"kind\":\"Pod\",\"metadata\":{\"annotations\":{\"cni.projectcalico.org/containerID\":\"1711ebd973183129e352c8937245da094a2fab7d0b27631978bb26dc43218c40\",\"cni.projectcalico.org/podIP\":\"192.168.1.5/32\",\"cni.projectcalico.org/podIPs\":\"192.168.1.5/32\"},\"creationTimestamp\":\"2025-09-05T05:30:30Z\",\"generation\":1,\"name\":\"my-pod-cka\",\"namespace\":\"default\",\"resourceVersion\":\"3120\",\"uid\":\"8aa4ac15-d9c0-44a0-92c6-5fb956e050a8\"},\"spec\":{\"containers\":[{\"image\":\"nginx\",\"imagePullPolicy\":\"Always\",\"name\":\"nginx-container\",\"resources\":{},\"terminationMessagePath\":\"/dev/termination-log\",\"terminationMessagePolicy\":\"File\",\"volumeMounts\":[{\"mountPath\":\"/var/www/html\",\"name\":\"shared-storage\"},{\"mountPath\":\"/var/run/secrets/kubernetes.io/serviceaccount\",\"name\":\"kube-api-access-zwxsm\",\"readOnly\":true}]},{\"command\":[\"tail\",\"-f\",\"/dev/null\"],\"image\":\"busybox\",\"name\":\"busybox\",\"volumeMounts\":[{\"mountPath\":\"/var/www/shared\",\"name\":\"shared-storage\",\"readOnly\":true}]}],\"dnsPolicy\":\"ClusterFirst\",\"enableServiceLinks\":true,\"nodeName\":\"node01\",\"preemptionPolicy\":\"PreemptLowerPriority\",\"priority\":0,\"restartPolicy\":\"Always\",\"schedulerName\":\"default-scheduler\",\"securityContext\":{},\"serviceAccount\":\"default\",\"serviceAccountName\":\"default\",\"terminationGracePeriodSeconds\":30,\"tolerations\":[{\"effect\":\"NoExecute\",\"key\":\"node.kubernetes.io/not-ready\",\"operator\":\"Exists\",\"tolerationSeconds\":300},{\"effect\":\"NoExecute\",\"key\":\"node.kubernetes.io/unreachable\",\"operator\":\"Exists\",\"tolerationSeconds\":300}],\"volumes\":[{\"name\":\"shared-storage\",\"persistentVolumeClaim\":{\"claimName\":\"my-pvc-cka\"}},{\"name\":\"kube-api-access-zwxsm\",\"projected\":{\"defaultMode\":420,\"sources\":[{\"serviceAccountToken\":{\"expirationSeconds\":3607,\"path\":\"token\"}},{\"configMap\":{\"items\":[{\"key\":\"ca.crt\",\"path\":\"ca.crt\"}],\"name\":\"kube-root-ca.crt\"}},{\"downwardAPI\":{\"items\":[{\"fieldRef\":{\"apiVersion\":\"v1\",\"fieldPath\":\"metadata.namespace\"},\"path\":\"namespace\"}]}}]}}]},\"status\":{\"conditions\":[{\"lastProbeTime\":null,\"lastTransitionTime\":\"2025-09-05T05:30:48Z\",\"status\":\"True\",\"type\":\"PodReadyToStartContainers\"},{\"lastProbeTime\":null,\"lastTransitionTime\":\"2025-09-05T05:30:38Z\",\"status\":\"True\",\"type\":\"Initialized\"},{\"lastProbeTime\":null,\"lastTransitionTime\":\"2025-09-05T05:30:48Z\",\"status\":\"True\",\"type\":\"Ready\"},{\"lastProbeTime\":null,\"lastTransitionTime\":\"2025-09-05T05:30:48Z\",\"status\":\"True\",\"type\":\"ContainersReady\"},{\"lastProbeTime\":null,\"lastTransitionTime\":\"2025-09-05T05:30:38Z\",\"status\":\"True\",\"type\":\"PodScheduled\"}],\"containerStatuses\":[{\"containerID\":\"containerd://b080c00c7813a42afabfafe6c420045202e160e4865af92d05d2a2403a586ca5\",\"image\":\"docker.io/library/nginx:latest\",\"imageID\":\"docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57\",\"lastState\":{},\"name\":\"nginx-container\",\"ready\":true,\"resources\":{},\"restartCount\":0,\"started\":true,\"state\":{\"running\":{\"startedAt\":\"2025-09-05T05:30:48Z\"}},\"volumeMounts\":[{\"mountPath\":\"/var/www/html\",\"name\":\"shared-storage\"},{\"mountPath\":\"/var/run/secrets/kubernetes.io/serviceaccount\",\"name\":\"kube-api-access-zwxsm\",\"readOnly\":true,\"recursiveReadOnly\":\"Disabled\"}]}],\"hostIP\":\"172.30.2.2\",\"hostIPs\":[{\"ip\":\"172.30.2.2\"}],\"phase\":\"Running\",\"podIP\":\"192.168.1.5\",\"podIPs\":[{\"ip\":\"192.168.1.5\"}],\"qosClass\":\"BestEffort\",\"startTime\":\"2025-09-05T05:30:38Z\"}}\n"},"creationTimestamp":"2025-09-05T05:30:30Z","resourceVersion":"3120","uid":"8aa4ac15-d9c0-44a0-92c6-5fb956e050a8"},"spec":{"$setElementOrder/containers":[{"name":"nginx-container"},{"name":"busybox"}],"containers":[{"$setElementOrder/volumeMounts":[{"mountPath":"/var/www/html"},{"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount"}],"name":"nginx-container","volumeMounts":[{"$patch":"delete","mountPath":"/var/www/shared"}]},{"$setElementOrder/volumeMounts":[{"mountPath":"/var/www/shared"}],"name":"busybox"}]},"status":{"$setElementOrder/conditions":[{"type":"PodReadyToStartContainers"},{"type":"Initialized"},{"type":"Ready"},{"type":"ContainersReady"},{"type":"PodScheduled"}],"$setElementOrder/podIPs":[{"ip":"192.168.1.5"}],"conditions":[{"lastTransitionTime":"2025-09-05T05:30:48Z","type":"PodReadyToStartContainers"},{"lastTransitionTime":"2025-09-05T05:30:38Z","type":"Initialized"},{"lastTransitionTime":"2025-09-05T05:30:48Z","type":"Ready"},{"lastTransitionTime":"2025-09-05T05:30:48Z","type":"ContainersReady"},{"lastTransitionTime":"2025-09-05T05:30:38Z","type":"PodScheduled"}],"containerStatuses":[{"containerID":"containerd://b080c00c7813a42afabfafe6c420045202e160e4865af92d05d2a2403a586ca5","image":"docker.io/library/nginx:latest","imageID":"docker.io/library/nginx@sha256:33e0bbc7ca9ecf108140af6288c7c9d1ecc77548cbfd3952fd8466a75edefe57","lastState":{},"name":"nginx-container","ready":true,"resources":{},"restartCount":0,"started":true,"state":{"running":{"startedAt":"2025-09-05T05:30:48Z"}},"volumeMounts":[{"mountPath":"/var/www/html","name":"shared-storage"},{"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount","name":"kube-api-access-zwxsm","readOnly":true,"recursiveReadOnly":"Disabled"}]}],"podIP":"192.168.1.5","podIPs":[{"ip":"192.168.1.5"}],"startTime":"2025-09-05T05:30:38Z"}}
to:
Resource: "/v1, Resource=pods", GroupVersionKind: "/v1, Kind=Pod"
Name: "my-pod-cka", Namespace: "default"
for: "pod.yaml": error when patching "pod.yaml": Operation cannot be fulfilled on pods "my-pod-cka": the object has been modified; please apply your changes to the latest version and try again
controlplane:~$ k delete -f pod.yaml && k apply -f pod.yaml
pod "my-pod-cka" deleted
pod/my-pod-cka created
controlplane:~$ k get pv pvc-3f7bfa4d-9692-4980-8bc8-efd9e675f064 -o yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  annotations:
    local.path.provisioner/selected-node: node01
    pv.kubernetes.io/provisioned-by: rancher.io/local-path
  creationTimestamp: "2025-09-05T05:30:37Z"
  finalizers:
  - kubernetes.io/pv-protection
  name: pvc-3f7bfa4d-9692-4980-8bc8-efd9e675f064
  resourceVersion: "3094"
  uid: 92e79e8a-7090-4c97-b80e-03dbed02ac90
spec:
  accessModes:
  - ReadWriteOnce
  capacity:
    storage: 100Mi
  claimRef:
    apiVersion: v1
    kind: PersistentVolumeClaim
    name: my-pvc-cka
    namespace: default
    resourceVersion: "3069"
    uid: 3f7bfa4d-9692-4980-8bc8-efd9e675f064
  hostPath:
    path: /opt/local-path-provisioner/pvc-3f7bfa4d-9692-4980-8bc8-efd9e675f064_default_my-pvc-cka
    type: DirectoryOrCreate
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - node01
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-path
  volumeMode: Filesystem
status:
  lastPhaseTransitionTime: "2025-09-05T05:30:37Z"
  phase: Bound
controlplane:~$ k get storageclass 
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  16d
controlplane:~$ k get storageclasses.storage.k8s.io local-path -o yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"local-path"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
    storageclass.kubernetes.io/is-default-class: "true"
  creationTimestamp: "2025-08-19T09:05:58Z"
  name: local-path
  resourceVersion: "805"
  uid: ea0ef5f9-cec9-41c1-8872-09f847d38a70
provisioner: rancher.io/local-path
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
controlplane:~$ k get pod my-pod-cka -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    cni.projectcalico.org/containerID: 3f3e022fc9902879521b7e6d0c1d2dff3f3dcac552080c1c43d66a9ad8fedf54
    cni.projectcalico.org/podIP: 192.168.1.7/32
    cni.projectcalico.org/podIPs: 192.168.1.7/32
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{"cni.projectcalico.org/containerID":"1711ebd973183129e352c8937245da094a2fab7d0b27631978bb26dc43218c40","cni.projectcalico.org/podIP":"192.168.1.5/32","cni.projectcalico.org/podIPs":"192.168.1.5/32"},"creationTimestamp":"2025-09-05T05:30:30Z","generation":1,"name":"my-pod-cka","namespace":"default","resourceVersion":"3120","uid":"8aa4ac15-d9c0-44a0-92c6-5fb956e050a8"},"spec":{"containers":[{"image":"nginx","imagePullPolicy":"Always","name":"nginx-container","resources":{},"terminationMessagePath":"/dev/termination-log","terminationMessagePolicy":"File","volumeMounts":[{"mountPath":"/var/www/html","name":"shared-storage"},{"mountPath":"/var/run/secrets/kubernetes.io/serviceaccount","name":"kube-api-access-zwxsm","readOnly":true}]},{"command":["tail","-f","/dev/null"],"image":"busybox","name":"busybox","volumeMounts":[{"mountPath":"/var/www/shared","name":"shared-storage","readOnly":true}]}],"dnsPolicy":"ClusterFirst","enableServiceLinks":true,"nodeName":"node01","preemptionPolicy":"PreemptLowerPriority","priority":0,"restartPolicy":"Always","schedulerName":"default-scheduler","securityContext":{},"serviceAccount":"default","serviceAccountName":"default","terminationGracePeriodSeconds":30,"tolerations":[{"effect":"NoExecute","key":"node.kubernetes.io/not-ready","operator":"Exists","tolerationSeconds":300},{"effect":"NoExecute","key":"node.kubernetes.io/unreachable","operator":"Exists","tolerationSeconds":300}],"volumes":[{"name":"shared-storage","persistentVolumeClaim":{"claimName":"my-pvc-cka"}},{"name":"kube-api-access-zwxsm","projected":{"defaultMode":420,"sources":[{"serviceAccountToken":{"expirationSeconds":3607,"path":"token"}},{"configMap":{"items":[{"key":"ca.crt","path":"ca.crt"}],"name":"kube-root-ca.crt"}},{"downwardAPI":{"items":[{"fieldRef":{"apiVersion":"v1","fieldPath":"metadata.


https://killercoda.com/sachin/course/CKA/Shared-Volume