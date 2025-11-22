#!/bin/bash
# cleanup-minikube.sh

set -e

MINIKUBE_PROFILE="minikube-calico"
LIBVIRT_NETWORK_NAME="minikube-net"

echo "Cleaning up Minikube setup..."

# Stop and delete minikube
minikube stop --profile="$MINIKUBE_PROFILE" 2>/dev/null || true
minikube delete --profile="$MINIKUBE_PROFILE" 2>/dev/null || true

# Destroy libvirt network
virsh net-destroy "$LIBVIRT_NETWORK_NAME" 2>/dev/null || true
virsh net-undefine "$LIBVIRT_NETWORK_NAME" 2>/dev/null || true

# Remove network XML file
rm -f "/tmp/${LIBVIRT_NETWORK_NAME}.xml"

echo "Cleanup completed!"
