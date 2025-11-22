https://killercoda.com/sachin/course/CKA/deployment-issue

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ vi postgres-deployment.yaml 
controlplane:~$ k get sec
error: the server doesn't have a resource type "sec"
controlplane:~$ k get secret
NAME              TYPE     DATA   AGE
postgres-secret   Opaque   2      59s
controlplane:~$ k get secret -o yaml 
apiVersion: v1
items:
- apiVersion: v1
  data:
    password: ZGJwYXNzd29yZAo=
    username: ZGJ1c2VyCg==
  kind: Secret
  metadata:
    annotations:
      kubectl.kubernetes.io/last-applied-configuration: |
        {"apiVersion":"v1","data":{"password":"ZGJwYXNzd29yZAo=","username":"ZGJ1c2VyCg=="},"kind":"Secret","metadata":{"annotations":{},"name":"postgres-secret","namespace":"default"},"type":"Opaque"}
    creationTimestamp: "2025-09-07T02:49:48Z"
    name: postgres-secret
    namespace: default
    resourceVersion: "5143"
    uid: 2008427e-cab3-4514-bc50-281e04f2b06f
  type: Opaque
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ vi postgres-deployment.yaml 
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k apply -f postgres-deployment.yaml 
deployment.apps/postgres-deployment created
controlplane:~$ k get po -w
NAME                                   READY   STATUS              RESTARTS   AGE
postgres-deployment-7db8b9499d-5wsrv   0/1     ContainerCreating   0          2s
postgres-deployment-7db8b9499d-5wsrv   1/1     Running             0          15s
^Ccontrolplane:~$ 