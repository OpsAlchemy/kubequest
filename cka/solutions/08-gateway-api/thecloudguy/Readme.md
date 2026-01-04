kind create cluster --name gatewayapi --image kindest/node:v1.34.0
kubectl apply --server-side -f https://github.com/kubernetes-sigs/gateway-api/releases/download/v1.4.0/experimental-install.yaml

CHART_VERSION="37.3.0" # traefik version v3.6.0
helm repo add traefik https://helm.traefik.io/traefik
helm repo update
helm search repo traefik --versions

cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/solutions/08-gateway-api/thecloudguy
helm install traefik traefik/traefik \
  --version "$CHART_VERSION" \
  --values ./values.yaml \
  --namespace traefik \
  --create-namespace

# check the pods
kubectl -n traefik get pods 

# check the logs 
kubectl -n traefik logs -l app.kubernetes.io/instance=traefik-traefik

# port forward for access
kubectl -n traefik port-forward svc/traefik 8008:80



kubectl apply -f golang.yaml
kubectl apply -f python.yaml
kubectl apply -f web.yaml


kubectl apply -f traefik/gatewayclass.yaml
kubectl apply -f traefik/gateway.yaml
kubectl apply -f httproute-by-host.yaml


sudo kubectl \
  --kubeconfig=$HOME/.kube/config \
  -n traefik \
  port-forward svc/traefik 80:80



kubectl apply -f httproute-by-pathprefix.yaml
kubectl apply -f httproute-by-pathrewrite.yaml


curl -L https://github.com/FiloSottile/mkcert/releases/download/v1.4.4/mkcert-v1.4.4-linux-amd64 -o mkcert && chmod +x mkcert && mv mkcert /usr/local/bin/

#linux
export CAROOT=${PWD}/kubernetes/gateway-api/tls
#windows
$env:CAROOT = "${PWD}" + "\kubernetes\gateway-api\tls"
mkcert -key-file kubernetes/gateway-api/tls/key.pem -cert-file kubernetes/gateway-api/tls/cert.pem example-app.localhost
mkcert -install
kubectl create secret tls secret-tls -n default --cert kubernetes/gateway-api/tls/cert.pem --key kubernetes/gateway-api/tls/key.pem

mkdir -p tls
export CAROOT=$(pwd)/tls

mkcert \
  -cert-file tls/cert.crt \
  -key-file  tls/key.key \
  example-app.localhost

https://github.com/marcel-dempers/docker-development-youtube-series/blob/master/kubernetes/gateway-api/05-httproute-by-path-rewrite.yaml

kubectl apply -f httproute-by-tls.yaml


cors
kubectl port-forward svc/web-app 8080:80

kubectl apply -f httproute-by-header.yaml