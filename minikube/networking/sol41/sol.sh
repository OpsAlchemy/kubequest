#!/bin/bash
create() {
  local name="$1"
  local text="$2"

cat<<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: ${name}-config
data:
  index.html: "$text"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
  labels:
    app: ${name}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ${name}
  template:
    metadata:
      labels:
        app: ${name}
    spec:
      containers:
      - name: nginx
        image: nginx:alpine
        ports:
        - containerPort: 80
        volumeMounts:
        - name: html-volume
          mountPath: /usr/share/nginx/html
      - name: curl
        image: curlimages/curl
        command: ["sh","-c","while true; do sleep 3600; done"]
      volumes:
      - name: html-volume
        configMap:
          name: ${name}-config
---
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: ${name}
  ports:
    - port: 80
      targetPort: 80
EOF
}

create api 'This is api'
create frontend 'This is frontend'

