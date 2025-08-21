#!/bin/bash

NAMESPACE="integration"

case "$1" in
  down)
    echo "Cleaning up resources in namespace '$NAMESPACE'..."
    kubectl delete ns $NAMESPACE
    ;;
  *)
    echo "Creating namespace '$NAMESPACE'..."
    kubectl create ns $NAMESPACE --dry-run=client -o yaml | kubectl apply -f -

    echo "Creating test pods with CPU stress..."

    for i in 1 2 3; do
      kubectl run cpu-burner-$i \
        --namespace=$NAMESPACE \
        --image=ubuntu \
        --labels="app=intensive" \
        --restart=Never \
        --command -- bash -c "apt update && apt install -y stress && stress --cpu $i"
    done
    ;;
esac

