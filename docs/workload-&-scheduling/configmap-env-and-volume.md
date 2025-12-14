# Using ConfigMaps as Environment Variables and Volumes

### Task Summary

* Create a ConfigMap named `trauerweide` with key-value content:

  ```
  tree=trauerweide
  ```
* Create the ConfigMap using an existing file `/root/cm.yaml`
* Create a Pod named `pod1` using image `nginx:alpine`
* Expose:

  * Key `tree` from ConfigMap `trauerweide` as environment variable `TREE1`
  * All keys from ConfigMap `birke` as files under `/etc/birke/`
* Verify both environment variable and volume access

---

## ConfigMap Creation

### From Literal

```
kubectl create cm trauerweide --from-literal=tree=trauerweide
```

### From File

```
kubectl create -f /root/cm.yaml
```

---

## Pod Specification

```
apiVersion: v1
kind: Pod
metadata:
  name: pod1
spec:
  volumes:
  - name: birke
    configMap:
      name: birke
  containers:
  - name: pod1
    image: nginx:alpine
    env:
    - name: TREE1
      valueFrom:
        configMapKeyRef:
          name: trauerweide
          key: tree
    volumeMounts:
    - name: birke
      mountPath: /etc/birke
```

---

## Verification

### Verify Environment Variable

```
kubectl exec pod1 -- env | grep TREE1
```

Expected output:

```
TREE1=trauerweide
```

### Verify Mounted ConfigMap Files

```
kubectl exec pod1 -- cat /etc/birke/tree
kubectl exec pod1 -- cat /etc/birke/level
kubectl exec pod1 -- cat /etc/birke/department
```

---

## Key Notes

* ConfigMap keys map directly to:

  * Environment variables
  * Individual files when mounted as volumes
* When mounted as a volume:

  * Each key becomes a file
  * File name equals the key
  * File content equals the value
* Changes to ConfigMaps:

  * Update mounted volumes automatically
  * Do **not** update environment variables in running Pods

