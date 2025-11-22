Create these configmaps and hten use it in pod! 
hada failure indentiation is real big issue man

``` yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  containers:
  - image: nginx:alpine
    name: nginx
    env:
    - name: TREE1
      valueFrom:
        configMapKeyRef:
          name: trauerweide
          key: tree
    volumeMounts:
    - name: birke-volume
      mountPath: "/etc/birke"
  volumes:
  - name: birke-volume
    configMap:
      name: birke
  restartPolicy: Never
---
apiVersion: v1
data:
  tree: birke
  level: "3"
  department: park
kind: ConfigMap
metadata:
  name: birke
---
apiVersion: v1
data:
  tree: trauerweide
  level: "3"
  department: park
kind: ConfigMap
metadata:
  name: trauerweide
```