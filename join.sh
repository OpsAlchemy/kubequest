STER_IP=$1
TOKEN=$2
CA_CERT_HASH=$3

if [ -z "$MASTER_IP" ] || [ -z "$TOKEN" ] || [ -z "$CA_CERT_HASH" ]; then
	  echo "Usage: $0 <MASTER_IP> <TOKEN> <CA_CERT_HASH>"
	    exit 1
fi

sudo kubeadm join ${MASTER_IP}:6443 \
	  --token ${TOKEN} \
	    --discovery-token-ca-cert-hash ${CA_CERT_HASH}

