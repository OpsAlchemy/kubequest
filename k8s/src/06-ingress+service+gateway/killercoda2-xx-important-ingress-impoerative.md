https://killercoda.com/sachin/course/CKA/ingress

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ vi ingress.yaml
controlplane:~$ k apply -f ingress.yaml 
ingress.networking.k8s.io/nginx-ingress-resource created
controlplane:~$ vi ingress.yaml 
controlplane:~$ kdf ingress.yaml 
Command 'kdf' not found, but can be installed with:
apt install kdf
controlplane:~$ k delete -f ingress.yaml 
ingress.networking.k8s.io "nginx-ingress-resource" deleted
controlplane:~$ kubectl create ingress nginx-ingress-resource --rule="/shop*=nginx-service:80"
--annotation=nginx.ingress.kubernetes.io/ssl-redirect="false"
ingress.networking.k8s.io/nginx-ingress-resource created
bash: --annotation=nginx.ingress.kubernetes.io/ssl-redirect=false: No such file or directory
controlplane:~$ k create pods
error: Unexpected args: [pods]
See 'kubectl create -h' for help and examples
controlplane:~$ k create ingress
error: exactly one NAME is required, got 0
See 'kubectl create ingress -h' for help and examples
controlplane:~$ kubectl create ingress nginx-ingress-resource --rule="/shop*=nginx-service:80"
--annotation=nginx.ingress.kubernetes.io/ssl-redirect="false"^C
controlplane:~$ ^C
controlplane:~$ k delete ingress
ingressclasses.networking.k8s.io  ingresses.networking.k8s.io       
controlplane:~$ k delete -f ingress.yaml 
ingress.networking.k8s.io "nginx-ingress-resource" deleted
controlplane:~$ kubectl create ingress nginx-ingress-resource --rule="/shop*=nginx-service:80" --annotation nginx.ingress.kubernetes.io/ssl-redirect="false"
ingress.networking.k8s.io/nginx-ingress-resource created
controlplane:~$ k get pods
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-6cfb98644c-z9zdw   1/1     Running   0          8m19s
controlplane:~$ k get ingress nginx-ingress-resource -o yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
  creationTimestamp: "2025-09-04T08:52:46Z"
  generation: 1
  name: nginx-ingress-resource
  namespace: default
  resourceVersion: "3693"
  uid: 985b321f-5345-42ce-bd75-415dbec96058
spec:
  rules:
  - http:
      paths:
      - backend:
          service:
            name: nginx-service
            port:
              number: 80
        path: /shop
        pathType: Prefix
status:
  loadBalancer: {}
controlplane:~$ 