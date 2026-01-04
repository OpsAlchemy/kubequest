#!/usr/bin/env bash
set -euo pipefail

DRY_RUN=0
VERIFY=0
INSTALL_DOCKER=0
INSTALL_KUBECTL=0
INSTALL_KIND=0
INSTALL_MINIKUBE=0
INSTALL_HELM=0
INSTALL_AZURE_CLI=0
INSTALL_AWS_CLI=0
INSTALL_TERRAFORM=0
INSTALL_ALL=0

usage() {
  cat <<EOF
Usage: $0 [options]
Options:
  --dry-run        Show what would be done, do not change system
  --verify         Verify installed versions
  --all            Install all supported tools
  --docker         Install Docker (via get.docker.com)
  --kubectl        Install kubectl
  --kind           Install kind
  --minikube       Install minikube
  --helm           Install Helm
  --azure-cli      Install Azure CLI
  --aws-cli        Install AWS CLI
  --terraform      Install Terraform
  -h, --help       Show this help

Examples:
  $0 --dry-run --all
  sudo $0 --all
  $0 --verify
EOF
}

install_docker() {
  if command -v docker >/dev/null 2>&1; then
    echo "Docker already installed: $(docker --version)"
    return
  fi
  echo "Installing Docker..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl -fsSL https://get.docker.com | sh"
  else
    curl -fsSL https://get.docker.com | sh
  fi
}

install_kubectl() {
  if command -v kubectl >/dev/null 2>&1; then
    echo "kubectl already installed: $(kubectl version --client 2>/dev/null | head -n 1 || kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -n 1)"
    return
  fi
  echo "Installing kubectl..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl + install kubectl from official release"
  else
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm -f kubectl
  fi
}

install_kind() {
  if command -v kind >/dev/null 2>&1; then
    echo "kind already installed: $(kind --version)"
    return
  fi
  echo "Installing kind..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl + install kind from github"
  else
    curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
    sudo chmod +x ./kind
    sudo mv ./kind /usr/local/bin/kind
  fi
}

install_minikube() {
  if command -v minikube >/dev/null 2>&1; then
    echo "minikube already installed: $(minikube version)"
    return
  fi
  echo "Installing minikube..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl + install minikube from google cloud storage"
  else
    curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
    sudo chmod +x minikube
    sudo mv minikube /usr/local/bin/
  fi
}

install_helm() {
  if command -v helm >/dev/null 2>&1; then
    echo "Helm already installed: $(helm version --short)"
    return
  fi
  echo "Installing Helm..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl + install helm from official script"
  else
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
  fi
}

install_azure_cli() {
  if command -v az >/dev/null 2>&1; then
    echo "Azure CLI already installed: $(az --version | head -n 1)"
    return
  fi
  echo "Installing Azure CLI..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"
  else
    # Run the official APT-based installer (requires sudo)
    curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

    echo "Verifying Azure CLI installation..."
    if command -v az >/dev/null 2>&1; then
      echo "az version:"
      az version || true
    else
      echo "Azure CLI install failed or 'az' not found in PATH."
      return 1
    fi
  fi
}

install_aws_cli() {
  if command -v aws >/dev/null 2>&1; then
    echo "AWS CLI already installed: $(aws --version)"
    return
  fi
  echo "Installing AWS CLI..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: download + install aws-cli from official"
  else
    TMPDIR=$(mktemp -d)
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "${TMPDIR}/awscliv2.zip"
    unzip -d "$TMPDIR" "${TMPDIR}/awscliv2.zip"
    sudo "${TMPDIR}/aws/install"
    rm -rf "$TMPDIR"
  fi
}

install_terraform() {
  if command -v terraform >/dev/null 2>&1; then
    echo "Terraform already installed: $(terraform version | head -n 1)"
    return
  fi
  echo "Installing Terraform..."
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY RUN: download + install terraform from hashicorp"
  else
    TERRAFORM_VERSION="1.7.0"
    TERRAFORM_URL="https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"
    TMPDIR=$(mktemp -d)
    curl -Lo "${TMPDIR}/terraform.zip" "$TERRAFORM_URL"
    unzip -d "$TMPDIR" "${TMPDIR}/terraform.zip"
    sudo mv "${TMPDIR}/terraform" /usr/local/bin/
    rm -rf "$TMPDIR"
  fi
}

verify_all() {
  echo "=== Verification ==="
  echo -n "docker: " ; command -v docker && docker --version || echo "not installed"
  echo -n "kubectl: " ; command -v kubectl && (kubectl version --client 2>/dev/null | head -n 1 || kubectl version --client --output=yaml 2>/dev/null | grep gitVersion | head -n 1) || echo "not installed"
  echo -n "kind: " ; command -v kind && kind --version || echo "not installed"
  echo -n "minikube: " ; command -v minikube && minikube version || echo "not installed"
  echo -n "helm: " ; command -v helm && helm version --short || echo "not installed"
  echo -n "azure-cli: " ; command -v az && az --version | head -n 1 || echo "not installed"
  echo -n "aws-cli: " ; command -v aws && aws --version || echo "not installed"
  echo -n "terraform: " ; command -v terraform && terraform version | head -n 1 || echo "not installed"
}

# parse args
while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=1 ;;
    --verify) VERIFY=1 ;;
    --all) INSTALL_ALL=1 ;;
    --docker) INSTALL_DOCKER=1 ;;
    --kubectl) INSTALL_KUBECTL=1 ;;
    --kind) INSTALL_KIND=1 ;;
    --minikube) INSTALL_MINIKUBE=1 ;;
    --helm) INSTALL_HELM=1 ;;
    --azure-cli) INSTALL_AZURE_CLI=1 ;;
    --aws-cli) INSTALL_AWS_CLI=1 ;;
    --terraform) INSTALL_TERRAFORM=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown arg: $1"; usage; exit 1 ;;
  esac
  shift
done

if [[ "$VERIFY" -eq 1 ]]; then
  verify_all
  exit 0
fi

if [[ "$INSTALL_ALL" -eq 1 ]]; then
  INSTALL_DOCKER=1
  INSTALL_KUBECTL=1
  INSTALL_KIND=1
  INSTALL_MINIKUBE=1
  INSTALL_HELM=1
  INSTALL_AZURE_CLI=1
  INSTALL_AWS_CLI=1
  INSTALL_TERRAFORM=1
fi

# If --dry-run is used alone, set --all for demonstration
if [[ "$DRY_RUN" -eq 1 && $INSTALL_DOCKER -eq 0 && $INSTALL_KUBECTL -eq 0 && $INSTALL_KIND -eq 0 && $INSTALL_MINIKUBE -eq 0 && $INSTALL_HELM -eq 0 && $INSTALL_AZURE_CLI -eq 0 && $INSTALL_AWS_CLI -eq 0 && $INSTALL_TERRAFORM -eq 0 ]]; then
  INSTALL_ALL=1
  INSTALL_DOCKER=1
  INSTALL_KUBECTL=1
  INSTALL_KIND=1
  INSTALL_MINIKUBE=1
  INSTALL_HELM=1
  INSTALL_AZURE_CLI=1
  INSTALL_AWS_CLI=1
  INSTALL_TERRAFORM=1
fi

if [[ $INSTALL_DOCKER -eq 0 && $INSTALL_KUBECTL -eq 0 && $INSTALL_KIND -eq 0 && $INSTALL_MINIKUBE -eq 0 && $INSTALL_HELM -eq 0 && $INSTALL_AZURE_CLI -eq 0 && $INSTALL_AWS_CLI -eq 0 && $INSTALL_TERRAFORM -eq 0 ]]; then
  usage
  exit 0
fi

# run installs (prompt before running if not dry-run)
if [[ $DRY_RUN -eq 0 ]]; then
  echo "About to perform installations. Press Ctrl-C to cancel or Enter to continue."
  read -r
fi

if [[ $INSTALL_DOCKER -eq 1 ]]; then
  install_docker
fi

if [[ $INSTALL_KUBECTL -eq 1 ]]; then
  install_kubectl
fi

if [[ $INSTALL_KIND -eq 1 ]]; then
  install_kind
fi

if [[ $INSTALL_MINIKUBE -eq 1 ]]; then
  install_minikube
fi

if [[ $INSTALL_HELM -eq 1 ]]; then
  install_helm
fi

if [[ $INSTALL_AZURE_CLI -eq 1 ]]; then
  install_azure_cli
fi

if [[ $INSTALL_AWS_CLI -eq 1 ]]; then
  install_aws_cli
fi

if [[ $INSTALL_TERRAFORM -eq 1 ]]; then
  install_terraform
fi

echo "Done. Run with --verify to check installed tools."
