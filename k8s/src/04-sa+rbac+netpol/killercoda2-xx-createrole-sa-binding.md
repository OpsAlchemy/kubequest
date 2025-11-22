controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k create sa app-account
serviceaccount/app-account created
controlplane:~$ k create role app-role-cka --verb=get --resource=pod
role.rbac.authorization.k8s.io/app-role-cka created
controlplane:~$ k create rolebinding --serviceaccount=default:app-account           
error: exactly one NAME is required, got 0
See 'kubectl create rolebinding -h' for help and examples
controlplane:~$ k create rolebinding app-role-binding-cka --serviceaccount=default:app-account --role=app-role
rolebinding.rbac.authorization.k8s.io/app-role-binding-cka created
controlplane:~$ k auth can-i --as=system:serviceaccount:default:app-account get pod
no - RBAC: role.rbac.authorization.k8s.io "app-role" not found
controlplane:~$ k auth can-i get pod --as=system:serviceaccount:default:app-account        
no - RBAC: role.rbac.authorization.k8s.io "app-role" not found
controlplane:~$ k create rolebinding app-role-binding-cka --serviceaccount=default:app-account --role=app-role-cka
error: failed to create rolebinding: rolebindings.rbac.authorization.k8s.io "app-role-binding-cka" already exists
controlplane:~$ k delete rolebinding app-role-cka
Error from server (NotFound): rolebindings.rbac.authorization.k8s.io "app-role-cka" not found
controlplane:~$ k delete rolebinding app-role-binding-cka
rolebinding.rbac.authorization.k8s.io "app-role-binding-cka" deleted
controlplane:~$ k create rolebinding app-role-binding-cka --serviceaccount=default:app-account --role=app-role-cka
rolebinding.rbac.authorization.k8s.io/app-role-binding-cka created
controlplane:~$ k auth can-i get pod --as=system:serviceaccount:default:app-account
yes
controlplane:~$ k auth can-i list pod --as=system:serviceaccount:default:app-account
no
controlplane:~$ k auth can-i create pod --as=system:serviceaccount:default:app-account
no

https://killercoda.com/sachin/course/CKA/sa-cr-crb-1