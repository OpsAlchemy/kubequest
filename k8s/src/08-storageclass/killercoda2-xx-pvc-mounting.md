controlplane:~$ k get sc -A
NAME                   PROVISIONER             RECLAIMPOLICY   VOLUMEBINDINGMODE      ALLOWVOLUMEEXPANSION   AGE
local-path (default)   rancher.io/local-path   Delete          WaitForFirstConsumer   false                  18d
controlplane:~$ vi sol.yaml
controlplane:~$ k apply -f sol.yaml --dry-run=client
persistentvolume/my-pv-cka created (dry run)
controlplane:~$ vi sol.yaml 
controlplane:~$ k apply -f sol.yaml --dry-run=client
persistentvolume/my-pv-cka created (dry run)
persistentvolumeclaim/my-pvc-cka created (dry run)
controlplane:~$ vi sol.yaml 
controlplane:~$ k apply -f sol.yaml --dry-run=client
persistentvolume/my-pv-cka created (dry run)
persistentvolumeclaim/my-pvc-cka created (dry run)
pod/my-pod-cka created (dry run)
controlplane:~$ k apply -f sol.yaml
persistentvolumeclaim/my-pvc-cka created
Error from server (Invalid): error when creating "sol.yaml": PersistentVolume "my-pv-cka" is invalid: spec.nodeAffinity: Required value: Local volume requires node affinity
Error from server (BadRequest): error when creating "sol.yaml": Pod in version "v1" cannot be handled as a Pod: strict decoding error: unknown field "spec.volumes[0].peristentVolumeClaim"
controlplane:~$ vi sol.yaml
controlplane:~$ k apply -f sol.yaml 
persistentvolumeclaim/my-pvc-cka unchanged
pod/my-pod-cka created
The PersistentVolume "my-pv-cka" is invalid: spec.nodeAffinity: Required value: Local volume requires node affinity
controlplane:~$ vi sol.yaml
controlplane:~$ cat sol.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv-cka
spec:
  capacity:
    storage: 100Mi
  storageClassName: standard
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /mnt/data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc-cka
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
  storageClassName: standard
  volumeName: my-pv-cka
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod-cka
spec:
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: my-pvc-cka
  containers:
  - name: my-container
    image: nginx
    volumeMounts:
    - name: shared-storage
      mountPath: /var/www/html
controlplane:~$ k apply -f sol.yaml
persistentvolume/my-pv-cka created
persistentvolumeclaim/my-pvc-cka unchanged
pod/my-pod-cka configured
controlplane:~$ 