kubectl create service externalname external-svc \
  --external-name www.google.com \
  --tcp 80 --dry-run=client -o yaml | kubectl apply -f -

kubectl create ingress external-ingress --class=nginx \
	--rule="/google=external-svc:80" \
	--annotation nginx.ingress.kubernetes.io/rewrite-target=/ \
	--dry-run=client -o yaml | kubectl apply -f -

