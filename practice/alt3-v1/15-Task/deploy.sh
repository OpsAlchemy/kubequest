# Create a new deployment
kubectl create deployment <name> --image=<image> --replicas=<count>

# Update container image in deployment
kubectl set image deployment/<name> <container-name>=<new-image> --record

# Scale the deployment
kubectl scale deployment <name> --replicas=<count>

# View rollout status (progress of update)
kubectl rollout status deployment/<name>

# View rollout history (revisions with change cause)
kubectl rollout history deployment/<name>

# View details of a specific revision
kubectl rollout history deployment/<name> --revision=<number>

# Roll back to previous revision
kubectl rollout undo deployment/<name>

# Roll back to a specific revision
kubectl rollout undo deployment/<name> --to-revision=<number>

# Pause rollout (useful to stage multiple changes)
kubectl rollout pause deployment/<name>

# Resume a paused rollout
kubectl rollout resume deployment/<name>

# Get current state of deployment
kubectl get deployment <name> -o wide

# View the replicaset(s) created by the deployment
kubectl get rs -l app=<label>

# Delete deployment
kubectl delete deployment <name>

