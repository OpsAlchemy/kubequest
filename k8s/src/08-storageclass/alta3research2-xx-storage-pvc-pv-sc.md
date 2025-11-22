controlplane:~$ k apply -f sol1.yaml --dry-run=server
storageclass.storage.k8s.io/fast-storage created (server dry run)
persistentvolumeclaim/mypvc created (server dry run)
The PersistentVolume "mypv" is invalid: spec: Required value: must specify a volume type
controlplane:~$ ls 
filesystem  sol.yaml  sol1.yaml
controlplane:~$ vi sol1.yaml
controlplane:~$ k apply -f sol1.yaml --dry-run=server
storageclass.storage.k8s.io/fast-storage created (server dry run)
persistentvolume/mypv created (server dry run)
persistentvolumeclaim/mypvc created (server dry run)
controlplane:~$ vi sol1.yaml
controlplane:~$ vi sol1.yaml
controlplane:~$ k apply -f sol1.yaml
storageclass.storage.k8s.io/fast-storage created
persistentvolumeclaim/mypvc created
controlplane:~$ k get pvc, pv
error: arguments in resource/name form must have a single resource and name
controlplane:~$ k get pvc,pv
NAME                          STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/mypvc   Pending                                      fast-storage   <unset>                 8s
controlplane:~$ k get pvc
NAME    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mypvc   Pending                                      fast-storage   <unset>                 11s
controlplane:~$ k get pvc -w    
NAME    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mypvc   Pending                                      fast-storage   <unset>                 17s
^Ccontrolplane:~$  k get sc 
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
fast-storage           rancher.io/local-path   Retain          Immediate              false                  23s
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  19d
controlplane:~$ k get pvc
NAME    STATUS    VOLUME   CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
mypvc   Pending                                      fast-storage   <unset>                 35s
controlplane:~$ k describe pvc
Name:          mypvc
Namespace:     default
StorageClass:  fast-storage
Status:        Pending
Volume:        
Labels:        <none>
Annotations:   volume.beta.kubernetes.io/storage-provisioner: rancher.io/local-path
               volume.kubernetes.io/storage-provisioner: rancher.io/local-path
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      
Access Modes:  
VolumeMode:    Filesystem
Used By:       <none>
Events:
  Type     Reason                Age                From                                                                                                Message
  ----     ------                ----               ----                                                                                                -------
  Normal   Provisioning          27s (x2 over 42s)  rancher.io/local-path_local-path-provisioner-5c94487ccb-gmwjg_2d9c0b7c-70c6-43cf-90b9-f0ce629659c4  External provisioner is provisioning volume for claim "default/mypvc"
  Warning  ProvisioningFailed    27s (x2 over 42s)  rancher.io/local-path_local-path-provisioner-5c94487ccb-gmwjg_2d9c0b7c-70c6-43cf-90b9-f0ce629659c4  failed to provision volume with StorageClass "fast-storage": configuration error, no node was specified
  Normal   ExternalProvisioning  1s (x4 over 42s)   persistentvolume-controller                                                                         Waiting for a volume to be created either by the external provisioner 'rancher.io/local-path' or manually by the system administrator. If volume creation is delayed, please verify that the provisioner is running and correctly registered.
controlplane:~$ k get sc
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
fast-storage           rancher.io/local-path   Retain          Immediate              false                  76s
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  19d
controlplane:~$ k get sc local-path -o yaml
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
controlplane:~$ cat sol1.yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: rancher.io/local-path
reclaimPolicy: Retain
volumeBindingMode: Immediate
# ---
# apiVersion: v1
# kind: PersistentVolume
# metadata:
#   name: mypv
# spec:
#   storageClassName: fast-storage
#   hostPath:
#     path: /data
#  accessModes:
#  - ReadWriteOnce
#  capacity:
#    storage: 100Mi
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  storageClassName: fast-storage
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
controlplane:~$ ^C
controlplane:~$ 


crazy question
https://youtu.be/eGv6iPWQKyo - before 8.24
