#!/bin/bash

case "$1" in
  down)
    echo "Deleting aloha deployment and service..."
    kubectl delete deployment aloha
    kubectl delete service aloha
    ;;

  pf)
    echo "Port-forwarding service 'aloha' on localhost:8483 → pod:80..."
    kubectl port-forward service/aloha 8483:54321
    ;;

  *)
    echo "Creating aloha deployment and service..."
    kubectl create deployment aloha --image=nginx --port=80 --replicas=2
    kubectl expose deployment aloha --port=54321 --target-port=80 --name=aloha
    ;;
esac

