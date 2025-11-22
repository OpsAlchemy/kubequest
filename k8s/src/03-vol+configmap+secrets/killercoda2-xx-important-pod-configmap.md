https://killercoda.com/sachin/course/CKA/pod-log


Your pod exited because `/bin/sh -c` was given split args. Use either a direct exec of `tail` or put the whole command after `-c` as one string. Here’s a working pod that tails the ConfigMap file and stays running.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod-pod
spec:
  containers:
  - name: alpine-container
    image: alpine:latest
    command: ["tail","-n","+1","-f","/config/log.txt"]
    volumeMounts:
    - name: config-volume
      mountPath: /config
  volumes:
  - name: config-volume
    configMap:
      name: log-configmap
```

Apply and check logs:
```bash
kubectl apply -f pod.yaml
kubectl logs -f alpine-pod-pod
```

If you prefer using a shell, do it like this (note the single string after `-c`):
```yaml
command: ["/bin/sh","-c","tail -n +1 -f /config/log.txt"]
```

Optional: if you only want a specific key from the ConfigMap or to rename it:
```yaml
volumes:
- name: config-volume
  configMap:
    name: log-configmap
    items:
    - key: log.txt
      path: log.txt
```


Here you go — both `command` and `args` used.

Option 1 (with shell):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod-pod
spec:
  containers:
  - name: alpine
    image: alpine:latest
    command: ["/bin/sh"]
    args: ["-c","tail -n +1 -F /config/log.txt"]
    volumeMounts:
    - name: cfg
      mountPath: /config
  volumes:
  - name: cfg
    configMap:
      name: log-configmap
      items:
      - key: log.txt
        path: log.txt
```

Option 2 (no shell, pure exec):

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: alpine-pod-pod
spec:
  containers:
  - name: alpine
    image: alpine:latest
    command: ["tail"]
    args: ["-n","+1","-F","/config/log.txt"]
    volumeMounts:
    - name: cfg
      mountPath: /config
  volumes:
  - name: cfg
    configMap:
      name: log-configmap
      items:
      - key: log.txt
        path: log.txt
```
