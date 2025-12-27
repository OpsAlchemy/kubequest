provisioner
volumeBindingMode
---
accessModes
storageClassName
capacity
hostPath
---
accessModes
resources
storageClassName

https://killercoda.com/sachin/course/CKA/sc-pv-pvc-pod

apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: blue-stc-cka
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: blue-pv-cka
spec:
  capacity:
    storage: 100Mi
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Retain
  storageClassName: blue-stc-cka
  local:
    path: /opt/blue-data-cka
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - controlplane
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: blue-pvc-cka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 50Mi
  storageClassName: blue-stc-cka
  volumeName: blue-pv-cka

---
controlplane:~$ k get sc -o yaml
apiVersion: v1
items:
- apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"local-path"},"provisioner":"rancher.io/local-path","reclaimPolicy":"Delete","volumeBindingMode":"WaitForFirstConsumer"}
      storageclass.kubernetes.io/is-default-class: "true"
    creationTimestamp: "2025-11-17T19:11:36Z"
    name: local-path
    resourceVersion: "821"
    uid: 2fa12284-994b-4e2c-811c-6efc5dd0c132
  provisioner: rancher.io/local-path
  reclaimPolicy: Delete
  volumeBindingMode: WaitForFirstConsumer
- allowVolumeExpansion: true
  apiVersion: storage.k8s.io/v1
  kind: StorageClass
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"allowVolumeExpansion":true,"apiVersion":"storage.k8s.io/v1","kind":"StorageClass","metadata":{"annotations":{},"name":"nginx-stc-cka"},"provisioner":"kubernetes.io/no-provisioner","volumeBindingMode":"WaitForFirstConsumer"}
    creationTimestamp: "2025-12-16T20:50:53Z"
    name: nginx-stc-cka
    resourceVersion: "6400"
    uid: dc8fa5cb-bf0f-4abb-a10e-8c9517d9d299
  provisioner: kubernetes.io/no-provisioner
  reclaimPolicy: Delete
  volumeBindingMode: WaitForFirstConsumer