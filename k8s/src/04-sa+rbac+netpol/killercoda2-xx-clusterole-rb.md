https://killercoda.com/sachin/course/CKA/sa-cr-crb


ontrolplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get group1-sa
error: the server doesn't have a resource type "group1-sa"
controlplane:~$ k get sa group1-sa -o yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  creationTimestamp: "2025-09-03T10:52:34Z"
  name: group1-sa
  namespace: default
  resourceVersion: "2941"
  uid: 7c1a2622-0b94-4616-878f-9b9c5bd1c6e8
controlplane:~$ k get clusterrole group1-role-cka
NAME              CREATED AT
group1-role-cka   2025-09-03T10:52:35Z
controlplane:~$ k get clusterrole group1-role-cka -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  creationTimestamp: "2025-09-03T10:52:35Z"
  name: group1-role-cka
  resourceVersion: "2942"
  uid: 66595125-78bd-4901-9a9c-15c6c1c787ab
rules:
- apiGroups:
  - apps
  resources:
  - deployments
  verbs:
  - get
controlplane:~$ k edit clusterrole group1-role-cka
clusterrole.rbac.authorization.k8s.io/group1-role-cka edited
controlplane:~$       