
case "$1" in
	create)
		kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
		;;
	delete)
		kubectl delete -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.3.0/standard-install.yaml
		;;
	custom)
		helm install traefik traefik/traefik --version 37.1.1 \
			--namespace traefik \
			--create-namespace \
			-f traefik-values.yaml
		;;
esac
