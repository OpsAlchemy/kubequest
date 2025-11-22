https://killercoda.com/chadmcrowell/course/cka/modify-cluster-dns

controlplane:~$ vi /etc/kubernetes/manifests/kube-apiserver.yaml 
controlplane:~$ cat /etc/kubernetes/manifests/kube-apiserver.yaml 
apiVersion: v1
kind: Pod
metadata:
  annotations:
    kubeadm.kubernetes.io/kube-apiserver.advertise-address.endpoint: 172.30.1.2:6443
  creationTimestamp: null
  labels:
    component: kube-apiserver
    tier: control-plane
  name: kube-apiserver
  namespace: kube-system
spec:
  containers:
  - command:
    - kube-apiserver
    - --advertise-address=172.30.1.2
    - --allow-privileged=true
    - --authorization-mode=Node,RBAC
    - --client-ca-file=/etc/kubernetes/pki/ca.crt
    - --enable-admission-plugins=NodeRestriction
    - --enable-bootstrap-token-auth=true
    - --etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
    - --etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
    - --etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
    - --etcd-servers=https://127.0.0.1:2379
    - --kubelet-client-certificate=/etc/kubernetes/pki/apiserver-kubelet-client.crt
    - --kubelet-client-key=/etc/kubernetes/pki/apiserver-kubelet-client.key
    - --kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
    - --proxy-client-cert-file=/etc/kubernetes/pki/front-proxy-client.crt
    - --proxy-client-key-file=/etc/kubernetes/pki/front-proxy-client.key
    - --requestheader-allowed-names=front-proxy-client
    - --requestheader-client-ca-file=/etc/kubernetes/pki/front-proxy-ca.crt
    - --requestheader-extra-headers-prefix=X-Remote-Extra-
    - --requestheader-group-headers=X-Remote-Group
    - --requestheader-username-headers=X-Remote-User
    - --secure-port=6443
    - --service-account-issuer=https://kubernetes.default.svc.cluster.local
    - --service-account-key-file=/etc/kubernetes/pki/sa.pub
    - --service-account-signing-key-file=/etc/kubernetes/pki/sa.key
    - --service-cluster-ip-range=100.96.0.0/12
    - --tls-cert-file=/etc/kubernetes/pki/apiserver.crt
    - --tls-private-key-file=/etc/kubernetes/pki/apiserver.key
    image: registry.k8s.io/kube-apiserver:v1.33.2
    imagePullPolicy: IfNotPresent
    livenessProbe:
      failureThreshold: 8
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    name: kube-apiserver
    readinessProbe:
      failureThreshold: 3
      httpGet:
        host: 172.30.1.2
        path: /readyz
        port: 6443
        scheme: HTTPS
      periodSeconds: 1
      timeoutSeconds: 15
    resources:
      requests:
        cpu: 50m
    startupProbe:
      failureThreshold: 24
      httpGet:
        host: 172.30.1.2
        path: /livez
        port: 6443
        scheme: HTTPS
      initialDelaySeconds: 10
      periodSeconds: 10
      timeoutSeconds: 15
    volumeMounts:
    - mountPath: /etc/ssl/certs
      name: ca-certs
      readOnly: true
    - mountPath: /etc/ca-certificates
      name: etc-ca-certificates
      readOnly: true
    - mountPath: /etc/kubernetes/pki
      name: k8s-certs
      readOnly: true
    - mountPath: /usr/local/share/ca-certificates
      name: usr-local-share-ca-certificates
      readOnly: true
    - mountPath: /usr/share/ca-certificates
      name: usr-share-ca-certificates
      readOnly: true
  hostNetwork: true
  priority: 2000001000
  priorityClassName: system-node-critical
  securityContext:
    seccompProfile:
      type: RuntimeDefault
  volumes:
  - hostPath:
      path: /etc/ssl/certs
      type: DirectoryOrCreate
    name: ca-certs
  - hostPath:
      path: /etc/ca-certificates
      type: DirectoryOrCreate
    name: etc-ca-certificates
  - hostPath:
      path: /etc/kubernetes/pki
      type: DirectoryOrCreate
    name: k8s-certs
  - hostPath:
      path: /usr/local/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-local-share-ca-certificates
  - hostPath:
      path: /usr/share/ca-certificates
      type: DirectoryOrCreate
    name: usr-share-ca-certificates
status: {}
controlplane:~$ # edit the kube-dns service in the kube-system namespace
controlplane:~$ kubectl -n kube-system edit svc kube-dns
error: services "kube-dns" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-1130610676.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ kubectl -n kube-system edit svc kube-dns^C
controlplane:~$ k -n kube-system get svc kube-dns -o yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  creationTimestamp: "2025-08-19T09:03:55Z"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "240"
  uid: d6ed1ffc-f455-420e-be66-1d5af432a354
spec:
  clusterIP: 10.96.0.10
  clusterIPs:
  - 10.96.0.10
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
  selector:
    k8s-app: kube-dns
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
controlplane:~$ k -n kube-system get svc kube-dns -o yaml
apiVersion: v1
kind: Service
metadata:
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
  creationTimestamp: "2025-08-19T09:03:55Z"
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  name: kube-dns
  namespace: kube-system
  resourceVersion: "240"
  uid: d6ed1ffc-f455-420e-be66-1d5af432a354
spec:
  clusterIP: 10.96.0.10
  clusterIPs:
  - 10.96.0.10
  internalTrafficPolicy: Cluster
  ipFamilies:
  - IPv4
  ipFamilyPolicy: SingleStack
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
  selector:
    k8s-app: kube-dns
  sessionAffinity: None
  type: ClusterIP
status:
  loadBalancer: {}
controlplane:~$ kubectl -n kube-system edit svc kube-dns
error: services "kube-dns" is invalid
A copy of your changes has been stored to "/tmp/kubectl-edit-1015794143.yaml"
error: Edit cancelled, no valid changes were saved.
controlplane:~$ k replace -f /tmp/kubectl-edit-1015794143.yaml 
The Service "kube-dns" is invalid: spec.clusterIPs[0]: Invalid value: []string{"100.96.0.10"}: may not change once set
controlplane:~$ k replace -f /tmp/kubectl-edit-1015794143.yaml  --force
service "kube-dns" deleted
The Service "kube-dns" is invalid: spec.clusterIPs: Invalid value: []string{"100.96.0.10"}: failed to allocate IP 100.96.0.10: the provided network does not match the current range
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
No resources found in kube-system namespace.
controlplane:~$ 
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
No resources found in kube-system namespace.
controlplane:~$ 
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
No resources found in kube-system namespace.
controlplane:~$ 
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
No resources found in kube-system namespace.
controlplane:~$ 
controlplane:~$ vi /etc/kubernetes/manifests/kube-apiserver.yaml 
controlplane:~$ k -n kube-system edit svc kube-dns
Error from server (NotFound): services "kube-dns" not found
controlplane:~$ k replace -f /tmp/kubectl-edit-1015794143.yaml  --force
The Service "kube-dns" is invalid: spec.clusterIPs: Invalid value: []string{"100.96.0.10"}: failed to allocate IP 100.96.0.10: the provided network does not match the current range
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
No resources found in kube-system namespace.
controlplane:~$ 
controlplane:~$ ^C
controlplane:~$ # Create a new kube-dns service YAML file
cat > kube-dns-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
spec:
  selector:
    k8s-app: kube-dns
  clusterIP: 100.96.0.10  # This should be within your service CIDR range
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
kubectl apply -f kube-dns-service.yaml
The Service "kube-dns" is invalid: spec.clusterIPs: Invalid value: []string{"100.96.0.10"}: failed to allocate IP 100.96.0.10: the provided network does not match the current range
controlplane:~$ ^C
controlplane:~$ # Create service without specifying clusterIP (let Kubernetes assign it)
cat > kube-dns-service.yaml << EOF
apiVersion: v1
kind: Service
metadata:
  name: kube-dns
  namespace: kube-system
  labels:
    k8s-app: kube-dns
    kubernetes.io/cluster-service: "true"
    kubernetes.io/name: CoreDNS
  annotations:
    prometheus.io/port: "9153"
    prometheus.io/scrape: "true"
spec:
  selector:
    k8s-app: kube-dns
  ports:
  - name: dns
    port: 53
    protocol: UDP
    targetPort: 53
  - name: dns-tcp
    port: 53
    protocol: TCP
    targetPort: 53
  - name: metrics
    port: 9153
    protocol: TCP
    targetPort: 9153
kubectl apply -f kube-dns-service.yaml
service/kube-dns created
controlplane:~$ # see the new IP address given to the service
controlplane:~$ k -n kube-system get svc
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.97.177.35   <none>        53/UDP,53/TCP,9153/TCP   3s
controlplane:~$ 
controlplane:~$ ^C
controlplane:~$ ^C
controlplane:~$ k get pod -n kube-system | grep kube-apiserver
kube-apiserver-controlplane               1/1     Running   0               5m56s
controlplane:~$ docker ps | grep kube-apiserver
controlplane:~$ cat /etc/kubernetes/manifests/kube-apiserver.yaml | grep service-cluster-ip-range
    - --service-cluster-ip-range=100.96.0.0/12
controlplane:~$ ^C
controlplane:~$ cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep cluster-cidr
cat /etc/kubernetes/manifests/kube-controller-manager.yaml | grep service-cluster
    - --cluster-cidr=192.168.0.0/16
    - --service-cluster-ip-range=10.96.0.0/12
controlplane:~$ ^C
controlplane:~$ vi /etc/kubernetes/manifests/kube-controller-manager.yaml
controlplane:~$ kubectl get pods -n kube-system -w | grep controller-manager
kube-controller-manager-controlplane      0/1     Pending   0               0s
kube-controller-manager-controlplane      0/1     ContainerCreating   0               0s
kube-controller-manager-controlplane      0/1     Running             0               0s
^C
controlplane:~$ kubectl delete svc kube-dns -n kube-system
service "kube-dns" deleted
controlplane:~$ kubectl apply -f kube-dns-service.yaml
service/kube-dns created
controlplane:~$ kubectl -n kube-system get svc kube-dns
NAME       TYPE        CLUSTER-IP     EXTERNAL-IP   PORT(S)                  AGE
kube-dns   ClusterIP   10.96.22.200   <none>        53/UDP,53/TCP,9153/TCP   7s
controlplane:~$ 







In order to change how new pods pick up their DNS info, change the kubelet config to use a cluster DNS of 100.96.0.10. Perform the change to the config.yaml on the node where pods run.

Then, edit the kubelet configMap in the kube-system namespace to use DNS 100.96.0.10. Reload the kubelet configuration without restarting the node.


Solution

# modify the kubelet config on the node
vim /var/lib/kubelet/config.yaml 
# within the config.yaml file, change the clusterDNS value to 100.96.0.10
...
cgroupDriver: systemd
clusterDNS:
- 100.96.0.10
clusterDomain: cluster.local
...
# edit kubelet configMap with 
k -n kube-system edit cm kubelet-config
# in the kubelet configMap, change the value for clusterDNS to 100.96.0.10
...
data:
  kubelet: |
    apiVersion: kubelet.config.k8s.io/v1beta1
    authentication:
      anonymous:
        enabled: false
      webhook:
        cacheTTL: 0s
        enabled: true
      x509:
        clientCAFile: /etc/kubernetes/pki/ca.crt
    authorization:
      mode: Webhook
      webhook:
        cacheAuthorizedTTL: 0s
        cacheUnauthorizedTTL: 0s
    cgroupDriver: systemd
    clusterDNS:
    - 100.96.0.10
    clusterDomain: cluster.local
...
# apply the update to the kubelet configuration immediately on the node
kubeadm upgrade node phase kubelet-config
systemctl daemon-reload
systemctl restart kubelet

