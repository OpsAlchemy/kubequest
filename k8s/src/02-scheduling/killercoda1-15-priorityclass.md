Absolute cienma

build the pod yaml using imperative commmand and add
priorityClassName: level-3



```yaml
ntrolplane:~$ k create pod important --image nginx:1.21.6-alpine --dry-client=client -o yaml > pod.yaml
error: unknown flag: --image
See 'kubectl create --help' for usage.
controlplane:~$ k run pod important --image nginx:1.21.6-alpine --dry-run=client -o yaml > pod.yaml
controlplane:~$ vi pod.yaml
controlplane:~$ k run pod --name important --image nginx:1.21.6-alpine --dry-run=client -o yaml > pod.yaml
error: unknown flag: --name
See 'kubectl run --help' for usage.
controlplane:~$ k run  important --image nginx:1.21.6-alpine --dry-run=client -o yaml > pod.yaml
controlplane:~$ vi pod.yaml
controlplane:~$ k apply -f pod.yaml
pod/important created
controlplane:~$ k get pods
NAME        READY   STATUS    RESTARTS   AGE
important   1/1     Running   0          2s
controlplane:~$ cat pod.yaml
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: important
  name: important
spec:
  containers:
  - image: nginx:1.21.6-alpine
    name: important
    resources:
      requests:
        memory: 1Gi
  dnsPolicy: ClusterFirst
  restartPolicy: Always
  priorityClassName: level3
status: {}
controlplane:~$ 
```