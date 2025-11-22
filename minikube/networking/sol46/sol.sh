#!/usr/bin/env bash
set -euo pipefail

create() {
  local name="$1"
  local text="$2"

  kubectl apply -f - <<EOF
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ${name}
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
        - name: ${name}-80
          image: vikashraj1825/netkit
          env:
            - name: TEXT
              value: "${text} (port 80)"
            - name: PORT
              value: "80"
          ports:
            - containerPort: 80
        - name: ${name}-443
          image: vikashraj1825/netkit
          env:
            - name: TEXT
              value: "${text} (port 443)"
            - name: PORT
              value: "443"
          ports:
            - containerPort: 443
        - name: ${name}-8080
          image: vikashraj1825/netkit
          env:
            - name: TEXT
              value: "${text} (port 8080)"
            - name: PORT
              value: "8080"
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: ${name}
  ports:
    - name: http
      port: 80
      targetPort: 80
      protocol: TCP
    - name: https
      port: 443
      targetPort: 443
      protocol: TCP
    - name: web8080
      port: 8080
      targetPort: 8080
      protocol: TCP
EOF
}

create api-server 'This is a api-server'
create check 'This is a checking application'

