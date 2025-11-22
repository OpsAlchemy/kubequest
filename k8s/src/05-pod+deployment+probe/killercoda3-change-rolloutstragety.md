https://killercoda.com/chadmcrowell/course/cka/change-rollout-strategy


controlplane:~$ k create deploy source-ip-app --image registry.k8s.io/echoserver:1.4
deployment.apps/source-ip-app created
controlplane:~$ k edit deployments.apps source-ip-app 
deployment.apps/source-ip-app edited
controlplane:~$ k set image deployments source-ip-app "*=registry.k8s.io/echoserver:1.3"
deployment.apps/source-ip-app image updated
controlplane:~$ k get po
NAME                             READY   STATUS    RESTARTS   AGE
source-ip-app-787b855d46-2s2vv   1/1     Running   0          22s
controlplane:~$ # change the image used for the 'source-ip-app' deployment
controlplane:~$ kubectl set image deploy source-ip-app echoserver=registry.k8s.io/echoserver:1.4 echoserver=registry.k8s.io/echoserver:1.3
controlplane:~$ 
controlplane:~$ # quickly check the pod as they recreate. notice how the old version of the pod is deleted immediately, not waiting for the new pods to create.
controlplane:~$ kubectl get po
NAME                             READY   STATUS    RESTARTS   AGE
source-ip-app-787b855d46-2s2vv   1/1     Running   0          30s
controlplane:~$ 
controlplane:~$ # change the image used for the 'source-ip-app' deployment
controlplane:~$ kubectl set image deploy source-ip-app echoserver=registry.k8s.io/echoserver:1.4 echoserver=registry.k8s.io/echoserver:1.3
controlplane:~$ 
controlplane:~$ # quickly check the pod as they recreate. notice how the old version of the pod is deleted immediately, not waiting for the new pods to create.
controlplane:~$ kubectl get po
NAME                             READY   STATUS    RESTARTS   AGE
source-ip-app-787b855d46-2s2vv   1/1     Running   0          33s
controlplane:~$ 
controlplane:~$ 


controlplane:~$ k get deploy nginx -o yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  annotations:
    deployment.kubernetes.io/revision: "1"
  creationTimestamp: "2025-09-02T16:56:51Z"
  generation: 1
  labels:
    app: nginx
  name: nginx
  namespace: default
  resourceVersion: "3541"
  uid: d0741011-8cda-4335-8b3d-920e24ae8bff
spec:
  progressDeadlineSeconds: 600
  replicas: 1
  revisionHistoryLimit: 10
  selector:
    matchLabels:
      app: nginx
  strategy:
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
    type: RollingUpdate
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: nginx
    spec:
      containers:
      - image: nginx
        imagePullPolicy: Always
        name: nginx
        resources: {}
        terminationMessagePath: /dev/termination-log
        terminationMessagePolicy: File
      dnsPolicy: ClusterFirst
      restartPolicy: Always
      schedulerName: default-scheduler
      securityContext: {}
      terminationGracePeriodSeconds: 30
status:
  availableReplicas: 1
  conditions:
  - lastTransitionTime: "2025-09-02T16:57:03Z"
    lastUpdateTime: "2025-09-02T16:57:03Z"
    message: Deployment has minimum availability.
    reason: MinimumReplicasAvailable
    status: "True"
    type: Available
  - lastTransitionTime: "2025-09-02T16:56:51Z"
    lastUpdateTime: "2025-09-02T16:57:03Z"
    message: ReplicaSet "nginx-5869d7778c" has successfully progressed.
    reason: NewReplicaSetAvailable
    status: "True"
    type: Progressing
  observedGeneration: 1
  readyReplicas: 1
  replicas: 1
  updatedReplicas: 1
controlplane:~$ 