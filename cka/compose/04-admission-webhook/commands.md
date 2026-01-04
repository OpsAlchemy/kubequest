## Bootstrap a kind cluster
kind create cluster --name webhook --image kindest/node:v1.29.2


## Generating Certificates and Shit!!

cd C:\Users\VikashKumar\Desktop\dev3\ops\kubequest\compose\04-admission-webhook\controllers
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/compose/04-admission-webhook/controllers

mkdir -p tls

docker run -it --rm -v ${PWD}:/work -w /work debian bash

apt-get update && apt-get install -y curl &&
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssl_1.5.0_linux_amd64 -o /usr/local/bin/cfssl && \
curl -L https://github.com/cloudflare/cfssl/releases/download/v1.5.0/cfssljson_1.5.0_linux_amd64 -o /usr/local/bin/cfssljson && \
chmod +x /usr/local/bin/cfssl && \
chmod +x /usr/local/bin/cfssljson

cat <<EOF >./tls/ca-csr.json
{
  "hosts": [
    "cluster.local"
  ],
  "key": {
    "algo": "rsa",
    "size": 2048
  },
  "names": [
    {
      "C": "AU",
      "L": "Melbourne",
      "O": "Example",
      "OU": "CA",
      "ST": "Example"
    }
  ]
}
EOF

cat <<EOF > tls/ca-config.json
{
  "signing": {
    "default": {
      "expiry": "175200h"
    },
    "profiles": {
      "default": {
        "usages": ["signing", "key encipherment", "server auth", "client auth"],
        "expiry": "175200h"
      }
    }
  }
}
EOF


#generate ca in /tmp
cfssl gencert -initca ./tls/ca-csr.json | cfssljson -bare /tmp/ca

#generate certificate in /tmp
cfssl gencert \
  -ca=/tmp/ca.pem \
  -ca-key=/tmp/ca-key.pem \
  -config=./tls/ca-config.json \
  -hostname="example-webhook,example-webhook.default.svc.cluster.local,example-webhook.default.svc,localhost,127.0.0.1" \
  -profile=default \
  ./tls/ca-csr.json | cfssljson -bare /tmp/example-webhook

#make a secret
cat <<EOF > ./tls/example-webhook-tls.yaml
apiVersion: v1
kind: Secret
metadata:
  name: example-webhook-tls
type: Opaque
data:
  tls.crt: $(cat /tmp/example-webhook.pem | base64 | tr -d '\n')
  tls.key: $(cat /tmp/example-webhook-key.pem | base64 | tr -d '\n') 
EOF

#generate CA Bundle + inject into template
ca_pem_b64="$(openssl base64 -A <"/tmp/ca.pem")"

sed -e 's@${CA_PEM_B64}@'"$ca_pem_b64"'@g' <"webhook-template.yaml" \
    > webhook.yaml

mkdir -p tls/ca

cp /tmp/ca.pem tls/ca/ca.pem
cp /tmp/ca-key.pem tls/ca/ca-key.pem

mkdir -p tls/webhook

cp /tmp/example-webhook.pem     tls/webhook/tls.crt
cp /tmp/example-webhook-key.pem tls/webhook/tls.key

## Go coding starting maaeen
cd C:\Users\VikashKumar\Desktop\dev3\ops\kubequest\compose\04-admission-webhook\controllers\src
cd /mnt/c/Users/VikashKumar/Desktop/dev3/ops/kubequest/compose/04-admission-webhook/controllers/src

docker build . -t webhook
docker run -it --rm -p 8081:80 -v ${PWD}:/app webhook sh
go mod init example-webhook
export CGO_ENABLED=0
go build -o webhook
./webhook



docker run -it --rm --net host -v ${HOME}/.kube/:/root/.kube/ -v ${PWD}:/app webhook sh

apk add --no-cache curl
curl -LO https://storage.googleapis.com/kubernetes-release/release/`curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt`/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl
apk add --no-cache make

cat <<'EOF' > Makefile
.PHONY: build run docker-build docker-push clean help

BINARY_NAME=webhook
GO_BUILD_FLAGS=CGO_ENABLED=0 GOOS=linux
DOCKER_IMAGE=webhook
DOCKER_TAG=latest
REGISTRY=your-registry.example.com

build:
	$(GO_BUILD_FLAGS) go build -o $(BINARY_NAME) .

run: build
	./$(BINARY_NAME)

docker-build:
	docker build . -t $(DOCKER_IMAGE):$(DOCKER_TAG)
	docker tag $(DOCKER_IMAGE):$(DOCKER_TAG) $(REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)

docker-push: docker-build
	docker push $(REGISTRY)/$(DOCKER_IMAGE):$(DOCKER_TAG)

clean:
	rm -f $(BINARY_NAME)

help:
	@echo "make build"
	@echo "make run"
	@echo "make docker-build"
	@echo "make docker-push"
	@echo "make clean"
EOF

go get k8s.io/apimachinery@v0.29.0
go get k8s.io/client-go@v0.29.0
go get k8s.io/api@v0.29.0