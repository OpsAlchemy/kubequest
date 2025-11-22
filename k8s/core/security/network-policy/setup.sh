#!/bin/bash
# setup.sh: network policy lab with frontend, backend, db
# Each pod runs a tiny Node.js HTTP server on its own port.

NAMESPACE=netpol-lab
COMPONENTS=("frontend" "backend" "db")

create_all() {
  echo "[+] Creating namespace $NAMESPACE..."
  kubectl create ns $NAMESPACE 2>/dev/null || true
  kubectl label ns $NAMESPACE purpose=netpol --overwrite

  echo "[+] Creating pods and services..."
  for comp in "${COMPONENTS[@]}"; do
    case "$comp" in
      frontend)
        PORT=80
        ;;
      backend)
        PORT=8080
        ;;
      db)
        PORT=3306
        ;;
    esac

    echo "[+] Creating $comp on port $PORT..."
    kubectl run $comp --image=node:18-alpine -n $NAMESPACE --restart=Never \
      --labels="app=$comp,tier=$comp" \
      -- sh -c "echo \"const http=require('http');http.createServer((req,res)=>{res.end('hello from $comp');}).listen($PORT);\" > server.js && node server.js"
    
    kubectl expose pod $comp --port=$PORT -n $NAMESPACE --name=$comp
  done

  echo "[+] Setup complete."
}

delete_all() {
  echo "[+] Deleting pods and services in $NAMESPACE..."
  for comp in "${COMPONENTS[@]}"; do
    kubectl delete pod $comp -n $NAMESPACE --ignore-not-found
    kubectl delete svc $comp -n $NAMESPACE --ignore-not-found
  done
}

status_all() {
  echo "[+] Pods in $NAMESPACE:"
  kubectl get pods -n $NAMESPACE -o wide --show-labels
  echo
  echo "[+] Services in $NAMESPACE:"
  kubectl get svc -n $NAMESPACE --show-labels
  echo
  echo "[+] Namespace labels:"
  kubectl get ns $NAMESPACE --show-labels
}

case "$1" in
  up)
    create_all
    ;;
  down)
    delete_all
    ;;
  status)
    status_all
    ;;
  *)
    echo "Usage: $0 {up|down|status}"
    exit 1
    ;;
esac
