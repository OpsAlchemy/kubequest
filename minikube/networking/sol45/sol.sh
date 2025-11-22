create() {
  local name="$1"
  local text="$2"
  local port="$3"
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
      name: pod1
      labels:
        app: ${name}
    spec:
      containers:
      - name: ${name}
        image: vikashraj1825/netkit
        env:
          - name: TEXT
            value: "${text}"
          - name: PORT
            value: "${port}"
---
apiVersion: v1
kind: Service
metadata:
  name: ${name}
spec:
  selector:
    app: ${name}
  ports:
    - port: ${port}
      targetPort: ${port}
      protocol: TCP
EOF
}

create dns-lookup 'This is a dns-lookup' 80
