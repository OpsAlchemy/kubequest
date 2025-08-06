#!/bin/bash

# Create Objects
kubectl run --image=nginx nginx 
kubectl create deployment --image=nginx nginx
kubectl expose deployment nginx --port 80

# Update Objects
kubectl edit deployment nginx
kubectl scale deployment nginx --replicas=5
kubectl set image deployment nginx=nginx:1.18

# Using Object Configuration File
kubectl create -f nginx.yaml
kubectl delete -f nginx.yaml
kubectl replace -f nginx.yaml

# Generate a pod manifest
kubectl run nginx --image=nginx --dry-run=client -o yaml
kubectl create deployment --image=nginx nginx --dry-run=client -o yaml
kubectl create deployment nginx --image=nginx --dry-run=client -o yaml > nginx-deployment.yaml

kubectl expose pod redis --port=6379 --name redis-service --dry-run=client -o yaml
kubectl create service clusterip redis --tcp=6379:6379 --dry-run=client -o yaml

# Create a Service named nginx of type NodePort to expose pod nginx's port 80 on port 30080 on the nodes:
kubectl expose pod nginx --type=NodePort --port=80 --name=nginx-service --dry-run=client -o yaml
kubectl create service nodeport nginx --tcp=80:80 --node-port=30080 --dry-run=client -o yaml

# https://kubernetes.io/docs/reference/generated/kubectl/kubectl-commands
# https://kubernetes.io/docs/reference/kubectl/conventions/
