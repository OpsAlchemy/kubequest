#!/bin/bash

# Step 1: Create deployment with an invalid image (will cause pods to fail)
kubectl create deployment mufasa --image=nginx:8484j --replicas=2

sleep 30

# Step 2: Update deployment with another invalid image
kubectl set image deployment/mufasa nginx=image:84jf

sleep 30

# Step 3: Fix the image and scale the deployment
kubectl set image deployment/mufasa nginx=nginx:1.21
kubectl scale deployment mufasa --replicas=3

# Step 4: Show rollout history
kubectl rollout history deployment/mufasa

