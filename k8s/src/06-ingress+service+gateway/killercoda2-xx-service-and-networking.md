controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k create pod nginx-pod-cka --image nginx   
error: unknown flag: --image
See 'kubectl create --help' for usage.
controlplane:~$ k run nginx-pod-cka --image nginx
pod/nginx-pod-cka created
controlplane:~$ k expose pod/nginx-pod-cka --name=nginx-service-cka --port=80 --target-port=80
service/nginx-service-cka exposed
controlplane:~$ k run pod --rm -it test-nslookup -^Cmage busybox:1.28 -- ns    
controlplane:~$ k get svc
NAME                TYPE        CLUSTER-IP      EXTERNAL-IP   PORT(S)   AGE
kubernetes          ClusterIP   10.96.0.1       <none>        443/TCP   16d
nginx-service-cka   ClusterIP   10.102.52.146   <none>        80/TCP    67s
controlplane:~$ nslookup test-nslookup
Server:         8.8.8.8
Address:        8.8.8.8#53

** server can't find test-nslookup: NXDOMAIN

controlplane:~$ k get svc^C
controlplane:~$ k run pod --rm -it test-nslookup --image busybox:1.28 -- nslookup nginx-service-cka        
pod "pod" deleted
error: timed out waiting for the condition
controlplane:~$ k run test-nslookup --image busybox:1.28 --command -- "sleep" "3600"
pod/test-nslookup created
controlplane:~$ k exec -it test-nslookup -- bash
error: Internal error occurred: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "87d90eacc3a48bebf9b553be18b3bcf727c4a5aa276edd6a56161635faf54475": OCI runtime exec failed: exec failed: unable to start container process: exec: "bash": executable file not found in $PATH: unknown
controlplane:~$ k get po
NAME            READY   STATUS    RESTARTS   AGE
nginx-pod-cka   1/1     Running   0          9m56s
test-nslookup   1/1     Running   0          13s
controlplane:~$ k exec -it test-nslookup -- bash
error: Internal error occurred: Internal error occurred: error executing command in container: failed to exec in container: failed to start exec "569f5b3004c80954f78f0c893a6eac11efca87a81d2393a46af2caec7d31d840": OCI runtime exec failed: exec failed: unable to start container process: exec: "bash": executable file not found in $PATH: unknown
controlplane:~$ k exec -it test-nslookup -- sh  
/ # nslookup google.com
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      google.com
Address 1: 2404:6800:4009:80e::200e bom07s20-in-x0e.1e100.net
Address 2: 142.250.192.78 bom12s16-in-f14.1e100.net
/ # nslookup nginx-service-cka
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-service-cka
Address 1: 10.102.52.146 nginx-service-cka.default.svc.cluster.local
/ # exit
controlplane:~$ k exec -it test-nslookup -- nslookup nginx-service-cka
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-service-cka
Address 1: 10.102.52.146 nginx-service-cka.default.svc.cluster.local
controlplane:~$ k exec -it test-nslookup -- nslookup nginx-service-cka > nginx-service.txt
controlplane:~$ kubectl run nginx-pod-cka --image=nginx --restart=Never
Error from server (AlreadyExists): pods "nginx-pod-cka" already exists
controlplane:~$ k delete pod nginx-pod-cka
pod "nginx-pod-cka" deleted
k controlplane:~$ k delete service nginx-service-cka 
service "nginx-service-cka" deleted
controlplane:~$ kubectl run nginx-pod-cka --image=nginx --restart=Never
pod/nginx-pod-cka created
controlplane:~$ kubectl expose pod nginx-pod-cka --name=nginx-service-cka --port=80
service/nginx-service-cka exposed
controlplane:~$ k delete test-nslookup
error: the server doesn't have a resource type "test-nslookup"
controlplane:~$ k delete pod test-nslookup
pod "test-nslookup" deleted
controlplane:~$ kubectl run test-nslookup --image=busybox:1.28 --restart=Never --rm -it -- nslookup nginx-service-cka
 >               
nginx-service.txt
bash: syntax error near unexpected token `newline'
nginx-service.txt: command not found
controlplane:~$ kubectl run test-nslookup --image=busybox:1.28 --restart=Never --rm -it -- nslookup nginx-service-cka > nginx-service.txt
controlplane:~$ ^C
controlplane:~$ cat nginx-service.txt 
Server:    10.96.0.10
Address 1: 10.96.0.10 kube-dns.kube-system.svc.cluster.local

Name:      nginx-service-cka
Address 1: 10.97.194.91 nginx-service-cka.default.svc.cluster.local
pod "test-nslookup" deleted
controlplane:~$ 

https://killercoda.com/sachin/course/CKA/nslookup