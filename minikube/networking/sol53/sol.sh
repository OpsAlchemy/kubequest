#!/bin/bash

echo "=== Task 1: Multi-Tier Application Network Isolation Setup ==="

# Create namespaces
echo "Creating namespaces..."
kubectl create namespace frontend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace backend --dry-run=client -o yaml | kubectl apply -f -
kubectl create namespace database --dry-run=client -o yaml | kubectl apply -f -

# Label namespaces
echo "Labeling namespaces..."
kubectl label namespace frontend tier=frontend --overwrite
kubectl label namespace backend tier=backend --overwrite
kubectl label namespace database tier=database --overwrite

# Deploy Frontend
echo "Deploying frontend application..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  namespace: frontend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: frontend
  template:
    metadata:
      labels:
        app: frontend
        tier: web
    spec:
      containers:
      - name: nginx
        image: nginx:1.19
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: frontend-service
  namespace: frontend
spec:
  selector:
    app: frontend
  ports:
  - port: 80
    targetPort: 80
  type: ClusterIP
EOF

# Deploy Backend
echo "Deploying backend application..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  namespace: backend
spec:
  replicas: 2
  selector:
    matchLabels:
      app: backend
  template:
    metadata:
      labels:
        app: backend
        tier: api
    spec:
      containers:
      - name: api-server
        image: registry.k8s.io/e2e-test-images/agnhost:2.39
        args:
        - netexec
        - --http-port=8080
        - --udp-port=8080
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: backend-service
  namespace: backend
spec:
  selector:
    app: backend
  ports:
  - port: 8080
    targetPort: 8080
  type: ClusterIP
EOF

# Deploy Database
echo "Deploying database application..."
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  namespace: database
spec:
  replicas: 1
  selector:
    matchLabels:
      app: database
  template:
    metadata:
      labels:
        app: database
        tier: db
    spec:
      containers:
      - name: mysql
        image: mysql:8.0
        env:
        - name: MYSQL_ROOT_PASSWORD
          value: password
        - name: MYSQL_DATABASE
          value: testdb
        ports:
        - containerPort: 3306
        readinessProbe:
          exec:
            command:
            - mysqladmin
            - ping
            - -h
            - localhost
            - -p password
          initialDelaySeconds: 5
          periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: database-service
  namespace: database
spec:
  selector:
    app: database
  ports:
  - port: 3306
    targetPort: 3306
  type: ClusterIP
EOF

# Wait for pods to be ready
echo "Waiting for pods to be ready..."
kubectl wait --for=condition=ready pod -l app=frontend -n frontend --timeout=60s
kubectl wait --for=condition=ready pod -l app=backend -n backend --timeout=60s
kubectl wait --for=condition=ready pod -l app=database -n database --timeout=120s

echo "=== Application deployment complete ==="
echo "Now create your network policies to implement the following rules:"
echo "1. Frontend can only communicate with backend on port 8080"
echo "2. Backend can only communicate with database on port 3306"
echo "3. Database accepts connections only from backend"
echo "4. No other inter-namespace communication is allowed"
echo "5. External traffic can reach frontend on port 80 only"
echo ""
echo "Create your NetworkPolicy YAML files and apply them with:"
echo "kubectl apply -f your-network-policies.yaml"
