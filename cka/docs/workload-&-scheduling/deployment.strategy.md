
Usage:
  kubectl set image (-f FILENAME | TYPE NAME) CONTAINER_NAME_1=CONTAINER_IMAGE_1 ... CONTAINER_NAME_N=CONTAINER_IMAGE_N
[options]

Use "kubectl options" for a list of global command-line options (applies to all commands).
controlplane:~$ cat sol.yaml             
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    app: cache
  name: cache-deployment
spec:
  replicas: 2
  selector:
    matchLabels:
      app: cache-deployment
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 25%
  template:
    metadata:
      labels:
        app: cache-deployment
    spec:
      containers:
      - image: redis:7.0.13
        name: redis
        resources: {}
status: {}
controlplane:~$ vi sol.yaml 
controlplane:~$ k apply -f sol.yaml
deployment.apps/cache-deployment configured
controlplane:~$ k set image deploy cache-deployment redis=redis:7.2.1
deployment.apps/cache-deployment image updated
controlplane:~$ 