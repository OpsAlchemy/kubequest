AME                               STATUS   VOLUME      CAPACITY   ACCESS MODES   STORAGECLASS   VOLUMEATTRIBUTESCLASS   AGE
persistentvolumeclaim/my-pvc-cka   Bound    my-pv-cka   100Mi      RWO            standard       <unset>                 7s
controlplane:~$ k get po
NAME         READY   STATUS    RESTARTS   AGE
my-pod-cka   1/1     Running   0          9s
controlplane:~$ cat sol.yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv-cka
spec:
  capacity:
    storage: 100Mi
  accessModes:
  - ReadWriteOnce
  hostPath:
    path: /mnt/data
  storageClassName: standard
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
      storage: 98Mi
  volumeName: my-pv-cka
  storageClassName: standard
---
apiVersion: v1
kind: Pod
metadata:
  name: my-pod-cka
spec:
  containers:
  - image: nginx
    name: container
    volumeMounts:
    - mountPath: /var/www/html
      name: storage
  volumes:
  - persistentVolumeClaim:
      claimName: my-pvc-cka
    name: storage
controlplane:~$ 