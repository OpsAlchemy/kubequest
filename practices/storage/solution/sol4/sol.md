controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get po
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   0/1     Pending   0          11s
controlplane:~$ kubectl describe po my-pod-cka 
Name:             my-pod-cka
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
  nginx-container:
    Image:        nginx
    Port:         <none>
    Host Port:    <none>
    Environment:  <none>
    Mounts:
      /var/run/secrets/kubernetes.io/serviceaccount from kube-api-access-jzwzk (ro)
      /var/www/html from shared-storage (rw)
Conditions:
  Type           Status
  PodScheduled   False 
Volumes:
  shared-storage:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  my-pvc-cka
    ReadOnly:   false
  kube-api-access-jzwzk:
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
  Warning  FailedScheduling  24s   default-scheduler  0/2 nodes are available: pod has unbound immediate PersistentVolumeClaims. not found
controlplane:~$ k get pv,pvc
NAME                         CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   VOLUMEATTRIBUTESCLASS   REASON   AGE
persistentvolume/my-pv-cka   100Mi      RWO            Retain           Available           standard       <unset>                          32s

NAME                               STATUS    VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/my-pvc-cka   Pending   my-pv-cka   0                         standard       <unset>                 32s
controlplane:~$ k get pv -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolume","metadata":{"annotations":{},"name":"my-pv-cka"},"spec":{"accessModes":["ReadWriteOnce"],"capacity":{"storage":"100Mi"},"hostPath":{"path":"/mnt/data"},"storageClassName":"standard"}}
    creationTimestamp: "2025-12-03T17:59:37Z"
    finalizers:
    - kubernetes.io/pv-protection
    name: my-pv-cka
    resourceVersion: "3113"
    uid: 948af6c4-cc5b-41bf-adb5-91b13715241a
  spec:
    accessModes:
    - ReadWriteOnce
    capacity:
      storage: 100Mi
    hostPath:
      path: /mnt/data
      type: ""
    persistentVolumeReclaimPolicy: Retain
    storageClassName: standard
    volumeMode: Filesystem
  status:
    lastPhaseTransitionTime: "2025-12-03T17:59:37Z"
    phase: Available
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get pvc -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"my-pvc-cka","namespace":"default"},"spec":{"accessModes":["ReadWriteMany"],"resources":{"requests":{"storage":"100Mi"}},"storageClassName":"standard","volumeName":"my-pv-cka"}}
    creationTimestamp: "2025-12-03T17:59:37Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: my-pvc-cka
    namespace: default
    resourceVersion: "3112"
    uid: 3af0a043-f745-4d98-af9b-388d435e6bf8
  spec:
    accessModes:
    - ReadWriteMany
    resources:
      requests:
        storage: 100Mi
    storageClassName: standard
    volumeMode: Filesystem
    volumeName: my-pv-cka
  status:
    phase: Pending
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k edit pvc
error: persistentvolumeclaims "my-pvc-cka" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-17556551.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k edit pvc my-pvc-cka
error: persistentvolumeclaims "my-pvc-cka" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-600454129.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k edit pvc my-pvc-cka
error: persistentvolumeclaims "my-pvc-cka" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-3023853411.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k get pvc -o yaml > sol.yaml
controlplane:~$ vi sol.yaml 
controlplane:~$ kaf sol.yaml
Command 'kaf' not found, did you mean:
  command 'kak' from deb kakoune (2022.10.31-2)
  command 'kf' from deb heimdal-clients (7.8.git20221117.28daf24+dfsg-3ubuntu4)
  command 'kdf' from deb kdf (4:23.08.4-0ubuntu1)
  command 'caf' from deb libcoarrays-mpich-dev (2.10.1-1)
  command 'caf' from deb libcoarrays-openmpi-dev (2.10.1-1)
  command 'kas' from deb kas (4.0-1)
  command 'paf' from deb libpod-abstract-perl (0.20-3)
  command 'kar' from deb sra-toolkit (3.0.3+dfsg-6ubuntu1)
Try: apt install <deb name>
controlplane:~$ kubectl replace -f sol.yaml --force
persistentvolumeclaim "my-pvc-cka" deleted from default namespace
persistentvolumeclaim/my-pvc-cka replaced
controlplane:~$ k get po
NAME         READY   STATUS              RESTARTS   AGE
my-pod-cka   0/1     ContainerCreating   0          11m
controlplane:~$ k get pvc
NAME         STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc-cka   Bound    my-pv-cka   100Mi      RWO            standard       <unset>                 7s
controlplane:~$ k get po
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   1/1     Running   0          11m
controlplane:~$ cat sol.yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"my-pvc-cka","namespace":"default"},"spec":{"accessModes":["ReadWriteOnce"],"resources":{"requests":{"storage":"100Mi"}},"storageClassName":"standard","volumeName":"my-pv-cka"}}
    creationTimestamp: "2025-12-03T17:59:37Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: my-pvc-cka
    namespace: default
    resourceVersion: "3112"
    uid: 3af0a043-f745-4d98-af9b-388d435e6bf8
  spec:
    accessModes:
    - ReadWriteOnce
    resources:
      requests:
        storage: 100Mi
    storageClassName: standard
    volumeMode: Filesystem
    volumeName: my-pv-cka
  status:
    phase: Pending
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ 