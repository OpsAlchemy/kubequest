#!/usr/bin/env bash
# minikube-all-in-one.sh
# Self-contained script: minikube (kvm2) + Calico + MetalLB (native) + example apps and services.
# Usage:
#   ./minikube-all-in-one.sh up     # create fresh cluster and deploy everything
#   ./minikube-all-in-one.sh down   # remove MetalLB and delete minikube
#   ./minikube-all-in-one.sh status # show status info and verification
set -euo pipefail

# ---------------------- Configuration (override via env) ----------------------
PROFILE="${PROFILE:-minikube}"
DRIVER="${DRIVER:-kvm2}"             # kvm2 driver (libvirt)
CPUS="${CPUS:-2}"
MEMORY="${MEMORY:-4096}"
DISK_SIZE="${DISK_SIZE:-20g}"
CNI="${CNI:-calico}"
WAIT_TIMEOUT="${WAIT_TIMEOUT:-240}"
MINIKUBE_DOWNLOAD="${MINIKUBE_DOWNLOAD:-https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64}"
METALLB_MANIFEST_URL="${METALLB_MANIFEST_URL:-https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml}"
METALLB_IP_RANGE="${METALLB_IP_RANGE:-192.168.39.100-192.168.39.150}"  # default from your metallb.yaml
MINIKUBE_BIN="${MINIKUBE_BIN:-$(command -v minikube || true)}"
KUBECTL_BIN="${KUBECTL_BIN:-$(command -v kubectl || true)}"
DOWNLOAD_MINIKUBE_TO="${DOWNLOAD_MINIKUBE_TO:-$HOME/.local/bin/minikube}"
# ------------------------------------------------------------------------------

log(){ printf "\n[+] %s\n" "$*"; }
err(){ printf "\n[!] ERROR: %s\n" "$*" >&2; exit 1; }

ensure_kubectl(){
  if [[ -z "${KUBECTL_BIN}" ]]; then
    err "kubectl not found. Install kubectl and ensure it's on PATH."
  fi
}

download_minikube_if_missing(){
  if [[ -n "${MINIKUBE_BIN}" && -x "${MINIKUBE_BIN}" ]]; then
    log "minikube present at ${MINIKUBE_BIN}"
    return
  fi
  log "minikube not found: downloading..."
  if command -v sudo >/dev/null 2>&1; then
    TARGET="/usr/local/bin/minikube"
    log "Downloading to ${TARGET} (requires sudo)..."
    sudo curl -Lo "${TARGET}" "${MINIKUBE_DOWNLOAD}"
    sudo chmod +x "${TARGET}"
    MINIKUBE_BIN="${TARGET}"
    log "minikube installed to ${TARGET}"
  else
    mkdir -p "$(dirname "${DOWNLOAD_MINIKUBE_TO}")"
    log "Downloading to ${DOWNLOAD_MINIKUBE_TO} (no sudo). Ensure ${HOME}/.local/bin is in PATH."
    curl -Lo "${DOWNLOAD_MINIKUBE_TO}" "${MINIKUBE_DOWNLOAD}"
    chmod +x "${DOWNLOAD_MINIKUBE_TO}"
    MINIKUBE_BIN="${DOWNLOAD_MINIKUBE_TO}"
    log "minikube downloaded to ${DOWNLOAD_MINIKUBE_TO}"
  fi
}

install_libvirt_prereqs_if_needed(){
  # Only attempt automatic install on Debian/Ubuntu systems with apt+sudo
  if ! command -v virsh >/dev/null 2>&1; then
    if command -v apt >/dev/null 2>&1 && command -v sudo >/dev/null 2>&1; then
      log "libvirt/qemu not found — installing via apt (sudo required)."
      sudo apt update
      sudo apt install -y qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils
      log "Installed libvirt/qemu packages. You may need to log out and back in for group membership."
      # try to start libvirt if not active
      if ! systemctl is-active --quiet libvirtd; then
        log "Starting libvirtd service..."
        sudo systemctl enable --now libvirtd
      fi
    else
      log "Automatic libvirt install skipped (no apt/sudo). Ensure libvirt/qemu-kvm is installed manually."
    fi
  else
    log "virsh found — libvirt likely installed."
  fi
}

start_minikube(){
  download_minikube_if_missing
  ensure_kubectl
  install_libvirt_prereqs_if_needed

  log "Deleting any existing minikube profile ${PROFILE} (clean start)..."
  "${MINIKUBE_BIN}" stop --profile="${PROFILE}" >/dev/null 2>&1 || true
  "${MINIKUBE_BIN}" delete --profile="${PROFILE}" >/dev/null 2>&1 || true

  log "Starting minikube: driver=${DRIVER}, cni=${CNI}, cpus=${CPUS}, memory=${MEMORY}"
  "${MINIKUBE_BIN}" start --profile="${PROFILE}" --driver="${DRIVER}" --cni="${CNI}" \
    --cpus="${CPUS}" --memory="${MEMORY}" --disk-size="${DISK_SIZE}"

  log "Waiting for node to be ready..."
  local wait=0
  while ! kubectl get node --no-headers >/dev/null 2>&1; do
    sleep 2
    wait=$((wait+2))
    (( wait > WAIT_TIMEOUT )) && err "Timed out waiting for kubectl to see node."
  done
  kubectl wait --for=condition=Ready node --all --timeout=120s || true
  log "Minikube started."
}

install_metallb_native(){
  ensure_kubectl
  log "Disabling minikube metallb addon (if enabled) to avoid conflicts..."
  "${MINIKUBE_BIN}" addons disable metallb --profile="${PROFILE}" >/dev/null 2>&1 || true

  log "Removing any existing native MetalLB resources (best-effort)..."
  kubectl delete -f "${METALLB_MANIFEST_URL}" --ignore-not-found --wait=false >/dev/null 2>&1 || true
  kubectl delete ns metallb-system --ignore-not-found --wait=false >/dev/null 2>&1 || true

  log "Installing native MetalLB from ${METALLB_MANIFEST_URL} ..."
  kubectl apply -f "${METALLB_MANIFEST_URL}"

  log "Waiting for metallb-system namespace to appear..."
  local waited=0
  while ! kubectl get ns metallb-system >/dev/null 2>&1; do
    sleep 2
    waited=$((waited+2))
    (( waited > WAIT_TIMEOUT )) && { log "Timed out waiting for metallb-system namespace; continue and check status later."; break; }
  done

  log "Applying MetalLB config (IPAddressPool + L2Advertisement) with IP range ${METALLB_IP_RANGE} ..."
  cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - ${METALLB_IP_RANGE}
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-advertisement
  namespace: metallb-system
spec:
  ipAddressPools:
  - default-pool
EOF

  log "Waiting briefly for MetalLB pods..."
  sleep 5
  kubectl get pods -n metallb-system -o wide || true
}

deploy_apps_selfcontained(){
  # Deploy frontend/backend/database with http-echo app + debug sidecar (netshoot)
  log "Applying example deployments and services (frontend, backend, database)..."
  cat <<'EOF' | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: frontend
  labels: {app: acme, tier: frontend}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: acme
      tier: frontend
  template:
    metadata:
      labels:
        app: acme
        tier: frontend
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text", "This is frontend", "-listen", ":5678"]
        ports:
        - containerPort: 5678
      - name: debug
        image: nicolaka/netshoot:latest
        command: ["sleep","1d"]
---
apiVersion: v1
kind: Service
metadata:
  name: frontend
spec:
  selector:
    app: acme
    tier: frontend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
  labels: {app: acme, tier: backend}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: acme
      tier: backend
  template:
    metadata:
      labels:
        app: acme
        tier: backend
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text", "This is backend", "-listen", ":5678"]
        ports:
        - containerPort: 5678
      - name: debug
        image: nicolaka/netshoot:latest
        command: ["sleep","1d"]
---
apiVersion: v1
kind: Service
metadata:
  name: backend
spec:
  selector:
    app: acme
    tier: backend
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
  type: ClusterIP
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: database
  labels: {app: acme, tier: database}
spec:
  replicas: 2
  selector:
    matchLabels:
      app: acme
      tier: database
  template:
    metadata:
      labels:
        app: acme
        tier: database
    spec:
      containers:
      - name: app
        image: hashicorp/http-echo
        args: ["-text", "This is database", "-listen", ":5678"]
        ports:
        - containerPort: 5678
      - name: debug
        image: nicolaka/netshoot:latest
        command: ["sleep","1d"]
---
apiVersion: v1
kind: Service
metadata:
  name: database
spec:
  selector:
    app: acme
    tier: database
  ports:
  - protocol: TCP
    port: 80
    targetPort: 5678
  type: ClusterIP
EOF

  log "Waiting for deployments to roll out..."
  kubectl rollout status deploy/frontend --timeout=120s || true
  kubectl rollout status deploy/backend --timeout=120s || true
  kubectl rollout status deploy/database --timeout=120s || true
}

verify_and_test(){
  log "=== Verification: MetalLB CRDs/resources ==="
  kubectl get crd | grep metallb || true
  kubectl get ipaddresspool -n metallb-system || true
  kubectl get l2advertisement -n metallb-system || true
  kubectl get all -n metallb-system || true

  log "=== NetworkPolicy list (all namespaces) ==="
  kubectl get networkpolicy --all-namespaces || true

  log "=== Calico pods (kube-system or calico-system) ==="
  kubectl get pods -n calico-system --ignore-not-found || kubectl get pods -n kube-system | grep -i calico || true

  log "=== Test MetalLB with LoadBalancer service (nginx-test) ==="
  kubectl create deployment nginx-test --image=nginx --replicas=1 || true
  kubectl expose deployment nginx-test --port=80 --type=LoadBalancer || true

  log "Waiting for external IP to appear on nginx-test (timeout ${WAIT_TIMEOUT}s)..."
  local waited=0
  while (( waited < WAIT_TIMEOUT )); do
    svc_ip=$(kubectl get svc nginx-test -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null || true)
    if [[ -n "${svc_ip}" ]]; then
      log "nginx-test LoadBalancer IP: ${svc_ip}"
      break
    fi
    sleep 2
    waited=$((waited+2))
  done
  if [[ -z "${svc_ip}" ]]; then
    log "No external IP assigned to nginx-test within ${WAIT_TIMEOUT}s. Use 'kubectl get svc nginx-test -o wide' to inspect."
    kubectl get svc nginx-test -o wide || true
    kubectl get events -n metallb-system --sort-by='.lastTimestamp' || true
  fi
}

do_up(){
  start_minikube
  install_metallb_native
  deploy_apps_selfcontained
  verify_and_test
  log "UP finished. Use './$0 status' for more details."
}

do_down(){
  log "Deleting test service/deployment (nginx-test) if present..."
  kubectl delete svc nginx-test --ignore-not-found || true
  kubectl delete deploy nginx-test --ignore-not-found || true

  log "Removing native MetalLB installation (manifest + namespace) — best-effort..."
  kubectl delete -f "${METALLB_MANIFEST_URL}" --ignore-not-found --wait=false || true
  kubectl delete ns metallb-system --ignore-not-found --wait=false || true

  log "Deleting example apps & services (frontend, backend, database)..."
  kubectl delete svc frontend backend database --ignore-not-found || true
  kubectl delete deploy frontend backend database --ignore-not-found || true

  log "Stopping and deleting minikube profile '${PROFILE}'..."
  if [[ -n "${MINIKUBE_BIN}" ]]; then
    "${MINIKUBE_BIN}" stop --profile="${PROFILE}" || true
    "${MINIKUBE_BIN}" delete --profile="${PROFILE}" || true
  fi
  log "DOWN finished."
}

do_status(){
  ensure_kubectl
  log "minikube version: $(${MINIKUBE_BIN} version 2>/dev/null || true)"
  log "kubectl cluster-info:"
  kubectl cluster-info || true
  log "Nodes:"
  kubectl get nodes -o wide || true
  log "Pods (first 200 lines):"
  kubectl get pods -A -o wide | sed -n '1,200p' || true
  log "--- MetalLB / Netpol / Calico ---"
  kubectl get ns metallb-system --ignore-not-found || true
  kubectl get pods -n metallb-system --ignore-not-found || true
  kubectl get ipaddresspool -n metallb-system --ignore-not-found || true
  kubectl get l2advertisement -n metallb-system --ignore-not-found || true
  kubectl get netpol --all-namespaces || true
  kubectl get pods -n calico-system --ignore-not-found || kubectl get pods -n kube-system | grep -i calico || true
}

# --------------------- main ---------------------
if [[ $# -lt 1 ]]; then
  cat <<EOF
Usage: $0 up|down|status

Commands:
  up     : create fresh minikube (kvm2), Calico, native MetalLB, example apps + services, and test LB
  down   : remove MetalLB, example apps, and delete minikube profile
  status : show cluster status, MetalLB & Calico info
EOF
  exit 1
fi

case "$1" in
  up) do_up ;;
  down) do_down ;;
  status) do_status ;;
  *) err "Unknown command: $1" ;;
esac

