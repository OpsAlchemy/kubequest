kubectl create deploy app --image hashicorp/http-echo --dry-run=client -o yaml | kubectl apply -f -
kubectl patch deploy app --type='json' --patch='[
	{
    "op": "add",
    "path": "/spec/template/spec/containers/0/args",
    "value": ["-text", "Hello from my awesome appliction"]
	}
]'
kubectl rollout status deploy app --timeout 120s
kubectl expose deployment/app --name app-svc --port=80 --target-port=5678 --type=ClusterIP --dry-run=client -o yaml | kubectl apply -f -
kubectl create ingress app --class=nginx \
	--rule="app.example.com/*=app-svc:80" \
	--annotation nginx.ingress.kubernetes.io/limit-rps=1 \
	--dry-run=client -o yaml | kubectl apply -f -

