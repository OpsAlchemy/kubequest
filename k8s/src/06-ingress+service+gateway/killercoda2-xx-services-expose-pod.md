controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k expose pod/nginx-pod --name=nginx-service --port=80 --target-port=80
service/nginx-service exposed
controlplane:~$ k port-forward svc/nginx-service 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^Ccontrolplane:~$ 



https://killercoda.com/sachin/course/CKA/svc