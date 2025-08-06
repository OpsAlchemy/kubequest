kubectl rollout status deployment/my-app-deployment

kubectl rollout history deployment/my-app-deployment

# Deployment strategy
# Recreate Strategy -> There will be downtime


# Rolling Update -> Default Strategy 
# Updating Image Version
# Updating Labels
# Updating Number Of Replicas

kubectl rollout undo deployment/myapp-deployment
kubectl rollout undo deployment my-app --to-revision=2
kubectl rollout history deployment my-app
