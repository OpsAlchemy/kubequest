https://killercoda.com/sachin/course/CKA/pod-issue-2

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get po redis-pod 
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          17s
controlplane:~$ k get po redis-pod -w
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          22s
^Ccontrolplane:~$ k get po redis-pod -o yaml
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Pod","metadata":{"annotations":{},"name":"redis-pod","namespace":"default"},"spec":{"containers":[{"image":"redis:latested","name":"redis-container","ports":[{"containerPort":6379,"name":"redis"}],"volumeMounts":[{"mountPath":"/data","name":"redis-data"}]}],"volumes":[{"name":"redis-data","persistentVolumeClaim":{"claimName":"pvc-redis"}}]}}
  creationTimestamp: "2025-09-07T02:16:17Z"
  generation: 1
  name: redis-pod
  namespace: default
  resourceVersion: "5177"
  uid: adf64a62-3cd5-4c4c-85b2-966822fe1a9e
spec:
  containers:
  - image: redis:latested
    imagePullPolicy: IfNotPresent
    name: redis-container
    ports:
    - containerPort: 6379
      name: redis
      protocol: TCP
    resources: {}
    terminationMessagePath: /dev/termination-log
    terminationMessagePolicy: File
    volumeMounts:
    - mountPath: /data
      name: redis-data
    - mountPath: /var/run/secrets/kubernetes.io/serviceaccount
      name: kube-api-access-fqc5l
      readOnly: true
  dnsPolicy: ClusterFirst
  enableServiceLinks: true
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
  - name: redis-data
    persistentVolumeClaim:
      claimName: pvc-redis
  - name: kube-api-access-fqc5l
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
    lastTransitionTime: "2025-09-07T02:16:17Z"
    message: '0/2 nodes are available: persistentvolumeclaim "pvc-redis" not found.
      preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.'
    reason: Unschedulable
    status: "False"
    type: PodScheduled
  phase: Pending
  qosClass: BestEffort
controlplane:~$ k edit po redis-pod 
pod/redis-pod edited
controlplane:~$ k get po -w
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          79s
^Ccontrolplane:~$ k get pvc
NAME        STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending                                      manually       <unset>                 83s
controlplane:~$ k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          87s
controlplane:~$ k get pvc -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"redis-pvc","namespace":"default"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"80Mi"}},"storageClassName":"manually"}}
    creationTimestamp: "2025-09-07T02:16:17Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: redis-pvc
    namespace: default
    resourceVersion: "5172"
    uid: c7b93b73-5e1e-4319-a4f5-3f9aa3adcb75
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 80Mi
    storageClassName: manually
    volumeMode: Filesystem
  status:
    phase: Pending
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get pv 
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          107s
controlplane:~$ k get pv -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolume","metadata":{"annotations":{},"name":"redis-pv"},"spec":{"accessModes":["ReadWriteOnce"],"capacity":{"storage":"100Mi"},"hostPath":{"path":"/mnt/data/redis"},"persistentVolumeReclaimPolicy":"Retain","storageClassName":"manual","volumeMode":"Filesystem"}}
    creationTimestamp: "2025-09-07T02:16:17Z"
    finalizers:
    - kubernetes.io/pv-protection
    name: redis-pv
    resourceVersion: "5173"
    uid: ccf9c39f-630b-4a07-8984-e962d122173a
  spec:
    accessModes:
    - ReadWriteOnce
    capacity:
      storage: 100Mi
    hostPath:
      path: /mnt/data/redis
      type: ""
    persistentVolumeReclaimPolicy: Retain
    storageClassName: manual
    volumeMode: Filesystem
  status:
    lastPhaseTransitionTime: "2025-09-07T02:16:17Z"
    phase: Available
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          2m53s
controlplane:~$ k get p
error: the server doesn't have a resource type "p"
controlplane:~$ k get po
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          2m57s
controlplane:~$ k edit pvc redis-pvc 
persistentvolumeclaim/redis-pvc edited
controlplane:~$ k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          3m19s
controlplane:~$ k get pvc -w
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 3m23s
^Ccontrolplane:~$ k get pvc
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 3m33s
controlplane:~$ k get po
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          3m38s
controlplane:~$ k describe po redis-pod 
Name:             redis-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           <none>
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Containers:
  redis-container:
    Image:        redis:latest
    Port:         6379/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /data from redis-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-fqc5l (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  redis-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  pvc-redis
    ReadOnly:   false
  kube-api-access-fqc5l:
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
  Type     Reason            Age    From               Message
  ----     ------            ----   ----               -------
  Warning  FailedScheduling  3m44s  default-scheduler  0/2 nodes are available: persistentvolumeclaim "pvc-redis" not found. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
controlplane:~$ k get pvc
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 3m53s
controlplane:~$ k edit po
error: pods "redis-pod" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-2832406860.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-2832406860.yaml --force
pod "redis-pod" deleted
pod/redis-pod replaced
controlplane:~$ k get po -w
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          3s
^Ccontrolplane:~$ k describe po redis-pod 
Name:             redis-pod
Namespace:        default
Priority:         0
Service Account:  default
Node:             <none>
Labels:           <none>
Annotations:      <none>
Status:           Pending
IP:               
IPs:              <none>
Containers:
  redis-container:
    Image:        redis:latest
    Port:         6379/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /data from redis-data (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-fqc5l (ro)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  redis-data:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  redis-pvc
    ReadOnly:   false
  kube-api-access-fqc5l:
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
  Type     Reason            Age   From               Message
  ----     ------            ----  ----               -------
  Warning  FailedScheduling  13s   default-scheduler  0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims. preemption: 0/2 nodes are available: 2 Preemption is not helpful for scheduling.
controlplane:~$ k get pvc
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 5m5s
controlplane:~$ k get pvc -w
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 5m20s
^Ccontrolplane:~$ k get pvc
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 5m27s
controlplane:~$ k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          5m29s
controlplane:~$ k get sc
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  18d
controlplane:~$ k get pvc
NAME        STATUS    VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Pending   redis-pv   0                         manually       <unset>                 5m53s
controlplane:~$ k describe pvc redis-pvc 
Name:          redis-pvc
Namespace:     default
StorageClass:  manually
Status:        Pending
Volume:        redis-pv
Labels:        <none>
Annotations:   <none>
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      0
Access Modes:  
VolumeMode:    Filesystem
Used By:       redis-pod
Events:
  Type     Reason              Age                     From                         Message
  ----     ------              ----                    ----                         -------
  Warning  ProvisioningFailed  2m53s (x14 over 5m59s)  persistentvolume-controller  storageclass.storage.k8s.io "manually" not found
  Warning  VolumeMismatch      8s (x12 over 2m42s)     persistentvolume-controller  Cannot bind to requested volume "redis-pv": storageClassName does not match
controlplane:~$ k get pv 
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          6m6s
controlplane:~$ k get sc
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  18d
controlplane:~$ k get pv
NAME       CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
redis-pv   100Mi      RWO            Retain           Available           manual         <unset>                          6m18s
controlplane:~$ k get pv -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolume","metadata":{"annotations":{},"name":"redis-pv"},"spec":{"accessModes":["ReadWriteOnce"],"capacity":{"storage":"100Mi"},"hostPath":{"path":"/mnt/data/redis"},"persistentVolumeReclaimPolicy":"Retain","storageClassName":"manual","volumeMode":"Filesystem"}}
    creationTimestamp: "2025-09-07T02:16:17Z"
    finalizers:
    - kubernetes.io/pv-protection
    name: redis-pv
    resourceVersion: "5173"
    uid: ccf9c39f-630b-4a07-8984-e962d122173a
  spec:
    accessModes:
    - ReadWriteOnce
    capacity:
      storage: 100Mi
    hostPath:
      path: /mnt/data/redis
      type: ""
    persistentVolumeReclaimPolicy: Retain
    storageClassName: manual
    volumeMode: Filesystem
  status:
    lastPhaseTransitionTime: "2025-09-07T02:16:17Z"
    phase: Available
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k edit pvc
error: persistentvolumeclaims "redis-pvc" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-2407002670.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-2407002670.yaml --force
persistentvolumeclaim "redis-pvc" deleted
persistentvolumeclaim/redis-pvc replaced
controlplane:~$ k get pos
error: the server doesn't have a resource type "pos"
controlplane:~$ k get pod
NAME        READY   STATUS    RESTARTS   AGE
redis-pod   0/1     Pending   0          2m20s
controlplane:~$ k get pvc
NAME        STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
redis-pvc   Bound    redis-pv   100Mi      RWO            manual         <unset>                 7s
controlplane:~$ k get po -w
NAME        READY   STATUS              RESTARTS   AGE
redis-pod   0/1     ContainerCreating   0          2m27s
redis-pod   1/1     Running             0          2m29s
^Ccontrolplane:~$   