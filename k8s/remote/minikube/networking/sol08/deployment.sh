#!/bin/bash

# Create shop-app deployment
kubectl create deployment shop-app --image=nginx:1.25 --replicas=1 --dry-run=client -o yaml > shop-deployment.yaml

cat <<EOF >> shop-deployment.yaml
        env:
        - name: APP_NAME
          value: "shopping app"
        ports:
        - containerPort: 80
EOF

kubectl apply -f shop-deployment.yaml

# Create blog-app deployment  
kubectl create deployment blog-app --image=nginx:1.25 --replicas=1 --dry-run=client -o yaml > blog-deployment.yaml

cat <<EOF >> blog-deployment.yaml
        env:
        - name: APP_NAME
          value: "blogging app"
        ports:
        - containerPort: 80
EOF

kubectl apply -f blog-deployment.yaml

# Clean up
rm shop-deployment.yaml blog-deployment.yaml
