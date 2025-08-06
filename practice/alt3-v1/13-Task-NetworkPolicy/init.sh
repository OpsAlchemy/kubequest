kubectl create deploy pit --image=nginx --replicas=2 --port=80
kubectl create deploy stem --image=nginx --replicas=2 --port=80

kubectl expose deploy pit --port=80 --target-port=80
kubectl expose deploy stem --port=80 --target-port=80

