https://killercoda.com/sachin/course/CKA/pvc

controlplane:~$ vi pvc.yaml
controlplane:~$ k apply -f pvc.yaml --dry-run=client
persistentvolumeclaim/red-pv-cka created (dry run)
controlplane:~$ k apply -f pvc.yaml                 
persistentvolumeclaim/red-pv-cka created
controlplane:~$ k get pvc
NAME         STATUS   VOLUME       CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
red-pv-cka   Bound    red-pv-cka   50Mi       RWO            manual         <unset>                 4s
controlplane:~$ cat pvc.yaml 
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: red-pv-cka
spec:
  resources:
    requests:
      storage: 30Mi
  accessModes:
  - ReadWriteOnce
  storageClassName: manual
  volumeName: red-pv-cka
controlplane:~$ 
