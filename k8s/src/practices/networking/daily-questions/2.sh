kubectl create deploy \
  nginx-deploy --image nginx:1.21  \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl expose deploy/nginx-deploy \
  --port 80
kubectl create ing nginx-ingress \
  --class=nginx \
  --rule="localhost/*=nginx-svc:80"
