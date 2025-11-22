https://killercoda.com/sachin/course/CKA/secret-1


controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get screts
error: the server doesn't have a resource type "screts"
controlplane:~$ k get secret
No resources found in default namespace.
controlplane:~$ k config set-context --current --namespace=database-ns
Context "kubernetes-admin@kubernetes" modified.
controlplane:~$ k get secret
NAME            TYPE     DATA   AGE
database-data   Opaque   1      43s
controlplane:~$ k get secret database-data -o yaml
apiVersion: v1
data:
  DB_PASSWORD: c2VjcmV0
kind: Secret
metadata:
  creationTimestamp: "2025-09-03T10:01:23Z"
  name: database-data
  namespace: database-ns
  resourceVersion: "3093"
  uid: 970d5903-6db6-45d4-95e0-887e141e2bfe
type: Opaque
controlplane:~$ echo "c2VjcmV0" | base64 --decode
secretcontrolplane:~$ echo "c2VjcmV0" | base64 --decode > decoded.txt
controlplane:~$ 