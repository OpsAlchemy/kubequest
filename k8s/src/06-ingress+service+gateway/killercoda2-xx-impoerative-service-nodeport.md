controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k create deploy my-web-app-deployment --replicas=2 --image=wordpress
deployment.apps/my-web-app-deployment created
controlplane:~$ k expose my-web-app-deployment --port=80 --target-port=80 --node-port=30770 --type=NodePort
error: unknown flag: --node-port
See 'kubectl expose --help' for usage.
controlplane:~$ ^C
controlplane:~$ kubectl create service nodeport my-web-app-service \
  --tcp=80:80 \
  --node-port=30770
service/my-web-app-service created
controlplane:~$ 



https://killercoda.com/sachin/course/CKA/nodeport-1