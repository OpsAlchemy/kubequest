helm uninstall traefik -n traefik

helm install traefik traefik/traefik --version 37.1.1 \
  --namespace traefik \
  --create-namespace \
  --set providers.kubernetesGateway.enabled=true \
  --set logs.access.enabled=true \
  --set ports.web.port=80 \
  --set ports.web.exposedPort=80 \
  --set ports.web.protocol=HTTP \
  --set "additionalArguments={--entrypoints.web.address=:80}" \
  --set gateway.enabled=false  # This disables the auto-Gateway creation
