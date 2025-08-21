kubectl create deploy deppy --image=nginx --replicas=2 
# Then update the deployment with proper port number and stuff
kubectl expose deploy deppy --type=NodePort
