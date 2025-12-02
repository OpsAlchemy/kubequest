kubectl create deploy shop-app --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -
kubectl create deploy blog-app --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -

kubectl patch deploy shop-app --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from shopping app"]}]' 
kubectl patch deploy blob-app --type='json' -p='[{"op":"add","path":"/spec/template/spec/containers/0/args","value":["-text","Hello from blogging app"]}]'

kubectl expose deploy shop-app --port=80 --target-port=5678
kubectl expose deploy blob-app --port=80 --target-port=5678


