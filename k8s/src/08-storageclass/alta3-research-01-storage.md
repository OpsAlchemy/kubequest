A developer needs a persistent volume for an application. Create a PersistentVolumeClaim with:
- Size 100Mi
- Access mode ReadWriteOnce
- Using the storage class "local-path"

Create a pod that mounts this PVC at /data and verify that the volume is automatically created and mounted.

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mypvc
spec:
  accessModes:
  - ReadWriteOnce
  storageClassName: local-path
  resources:
    requests:
      storage: 100Mi
---
apiVersion: v1
kind: Pod
metadata:
  name: mypod
spec:
  volumes:
  - name: shared-storage
    persistentVolumeClaim:
      claimName: mypvc
  containers:
  - image: nginx
    name: nginx
    volumeMounts:
    - name: shared-storage
      mountPath: /data
```
