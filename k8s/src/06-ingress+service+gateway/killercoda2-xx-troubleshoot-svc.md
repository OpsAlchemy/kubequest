controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k get endpoints
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME            ENDPOINTS         AGE
kubernetes      172.30.1.2:6443   18d
nginx-service   <none>            14s
controlplane:~$ k get svc
NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)   AGE
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP   18d
nginx-service   ClusterIP   10.102.147.160   <none>        80/TCP    19s
controlplane:~$ k get svc nginx-service -o yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"name":"nginx-service","namespace":"default"},"spec":{"ports":[{"port":80,"protocol":"TCP","targetPort":80}],"selector":{"app":"nginx-pod"}}}
  creationTimestamp: "2025-09-07T02:52:42Z"
  name: nginx-service
  namespace: default
  resourceVersion: "4751"
  uid: a7c55973-fff3-49f3-8f61-938fd074b1d5
spec:
  clusterIP: 10.102.147.160
  clusterIPs:
  - 10.102.147.160
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - port: 80
    protocol: TCP
    targetPort: 80
  selector:
    app: nginx-pod
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
controlplane:~$ k get po nginx-pod -o yaml | grep -i label
controlplane:~$ k label po nginx-pod app=nginx-pod
pod/nginx-pod labeled
controlplane:~$ k get endpoint -w
error: the server doesn't have a resource type "endpoint"
controlplane:~$ k get endpoints -w
Warning: v1 Endpoints is deprecated in v1.33+; use discovery.k8s.io/v1 EndpointSlice
NAME            ENDPOINTS         AGE
kubernetes      172.30.1.2:6443   18d
nginx-service   192.168.1.4:80    61s
^Ccontrolplane:~$ curl http://localhost:8080
curl: (7) Failed to connect to localhost port 8080 after 0 ms: Couldn't connect to server
controlplane:~$ k port-forward svc/nginx-service 8080:80
Forwarding from 127.0.0.1:8080 -> 80
Forwarding from [::1]:8080 -> 80
Handling connection for 8080
^Ccontrolplane:~$ 


https://killercoda.com/sachin/course/CKA/pod-issue-8