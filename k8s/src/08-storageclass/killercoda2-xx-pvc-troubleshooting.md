controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get pvc -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolumeClaim
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolumeClaim","metadata":{"annotations":{},"name":"my-pvc","namespace":"default"},"spec":{"accessModes":["ReadWriteMany"],"resources":{"requests":{"storage":"150Mi"}},"storageClassName":"standard"}}
    creationTimestamp: "2025-09-07T10:12:39Z"
    finalizers:
    - kubernetes.io/pvc-protection
    name: my-pvc
    namespace: default
    resourceVersion: "3219"
    uid: 8cc2ea73-d0cf-4f59-a67b-a66e6c8ac780
  spec:
    accessModes:
    - ReadWriteMany
    resources:
      requests:
        storage: 150Mi
    storageClassName: standard
    volumeMode: Filesystem
  status:
    phase: Pending
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get pv -o yaml
apiVersion: v1
items:
- apiVersion: v1
  kind: PersistentVolume
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","kind":"PersistentVolume","metadata":{"annotations":{},"name":"my-pv"},"spec":{"accessModes":["ReadWriteOnce"],"capacity":{"storage":"100Mi"},"hostPath":{"path":"/mnt/data"},"persistentVolumeReclaimPolicy":"Retain","storageClassName":"standard"}}
    creationTimestamp: "2025-09-07T10:12:39Z"
    finalizers:
    - kubernetes.io/pv-protection
    name: my-pv
    resourceVersion: "3220"
    uid: 0cac8dc6-defa-4861-ab1d-25fd8ad1d04a
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
    lastPhaseTransitionTime: "2025-09-07T10:12:39Z"
    phase: Available
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k edit pvc my-pvc 
error: persistentvolumeclaims "my-pvc" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-682733718.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-682733718.yaml --force
persistentvolumeclaim "my-pvc" deleted
persistentvolumeclaim/my-pvc replaced
controlplane:~$ k get pvc
NAME     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc   Pending                                      standard       <unset>                 7s
controlplane:~$ k get pvc -w
NAME     STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc   Pending                                      standard       <unset>                 10s
^Ccontrolplane:~$ k edit pvc 
error: persistentvolumeclaims "my-pvc" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-3293712073.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-3293712073.yaml --force
persistentvolumeclaim "my-pvc" deleted
persistentvolumeclaim/my-pvc replaced
controlplane:~$ k get pvc -w
NAME     STATUS   VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
my-pvc   Bound    my-pv    100Mi      RWO            standard       <unset>                 3s



https://killercoda.com/sachin/course/CKA/pv-pvc-issue