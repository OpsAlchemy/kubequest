https://killercoda.com/sachin/course/CKA/controller-manager-issue

controlplane:~$ kubectl config use-context kubernetes-admin@kubernetes
Switched to context "kubernetes-admin@kubernetes".
controlplane:~$ k scale deployment video-app  --replicas 2
deployment.apps/video-app scaled
controlplane:~$ k get po -w
^Ccontrolplane:~$ k get deploy
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
video-app   0/2     0            0           39s
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k describe deployments.apps video-app 
Name:                   video-app
Namespace:              default
CreationTimestamp:      Tue, 16 Dec 2025 22:38:55 +0000
Labels:                 app=video-app
Annotations:            <none>
Selector:               app=video-app
Replicas:               2 desired | 0 updated | 0 total | 0 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=video-app
  Containers:
   redis:
    Image:         redis:7.2.1
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:            <none>
controlplane:~$ k edit deployments.apps 
Edit cancelled, no changes made.
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k get deployments.apps 
NAME        READY   UP-TO-DATE   AVAILABLE   AGE
video-app   0/2     0            0           113s
controlplane:~$ k get deployments.apps  -o yaml
apiVersion: v1
items:
- apiVersion: apps/v1
  kind: Deployment
  metadata:
    creationTimestamp: "2025-12-16T22:38:55Z"
    generation: 1
    labels:
      app: video-app
    name: video-app
    namespace: default
    resourceVersion: "5797"
    uid: 4875a4f6-f05c-45bb-95ef-d9370a6c24b5
  spec:
    progressDeadlineSeconds: 600
    replicas: 2
    revisionHistoryLimit: 10
    selector:
      matchLabels:
        app: video-app
    strategy:
      rollingUpdate:
        maxSurge: 25%
        maxUnavailable: 25%
      type: RollingUpdate
    template:
      metadata:
        labels:
          app: video-app
      spec:
        containers:
        - image: redis:7.2.1
          imagePullPolicy: IfNotPresent
          name: redis
          resources: {}
          terminationMessagePath: /dev/termination-log
          terminationMessagePolicy: File
        dnsPolicy: ClusterFirst
        restartPolicy: Always
        schedulerName: default-scheduler
        securityContext: {}
        terminationGracePeriodSeconds: 30
  status: {}
kind: List
metadata:
  resourceVersion: ""
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k get no    
NAME           STATUS   ROLES           AGE   VERSION
controlplane   Ready    control-plane   29d   v1.34.1
node01         Ready    <none>          29d   v1.34.1
controlplane:~$ k get po
No resources found in default namespace.
controlplane:~$ k describe deploy
Name:                   video-app
Namespace:              default
CreationTimestamp:      Tue, 16 Dec 2025 22:38:55 +0000
Labels:                 app=video-app
Annotations:            <none>
Selector:               app=video-app
Replicas:               2 desired | 0 updated | 0 total | 0 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=video-app
  Containers:
   redis:
    Image:         redis:7.2.1
    Port:          <none>
    Host Port:     <none>
    Environment:   <none>
    Mounts:        <none>
  Volumes:         <none>
  Node-Selectors:  <none>
  Tolerations:     <none>
Events:            <none>
controlplane:~$ ^C
controlplane:~$ 