```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: fast-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: Immediate
---
apiVersion: v1
kind: PersistentVolume
gg:
  name: fast-pv-cka
spec:
  capacity:
    storage: 50Mi
  accessModes:
    - ReadWriteOnce
  storageClassName: fast-storage
  hostPath:
    path: /tmp/fast-data
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: fast-pvc-cka
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 30Mi
  storageClassName: fast-storage
  volumeName: fast-pv-cka
---
apiVersion: v1
kind: Pod
metadata:
  name: fast-pod-cka
spec:
  containers:
    - name: nginx
      image: nginx:latest
      volumeMounts:
        - name: fast-storage-vol
          mountPath: /app/data
  volumes:
    - name: fast-storage-vol
      persistentVolumeClaim:
        claimName: fast-pvc-cka

```