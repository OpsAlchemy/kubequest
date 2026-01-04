# Initial setup

This page provides a concise, general initial setup for local development and cluster experiments. It lists common tools and quick install commands. Use the sections below as a checklist and reference — they are intentionally short and platform-focused (Linux examples are shown; adapt for macOS/Windows as needed).

## Quick checklist

- [ ] Docker (container runtime)
- [ ] kubectl (Kubernetes CLI)
- [ ] kind (Kubernetes IN Docker) or k3d
- [ ] Minikube (alternative to kind)
- [ ] Helm (package manager)
- [ ] Azure CLI (Azure cloud CLI)
- [ ] AWS CLI (AWS cloud CLI)
- [ ] Terraform (Infrastructure as Code)

---

## Docker (Linux)

Quick install (convenience script):

```bash
curl -fsSL https://get.docker.com | sh
```

Tips:
- Run as a user with sudo or root.
- Start and enable Docker with systemd:
  ```bash
  sudo systemctl start docker
  sudo systemctl enable docker
  ```
- Add your user to the `docker` group to avoid sudo:
  ```bash
  sudo usermod -aG docker $USER
  newgrp docker  # or log out/in
  ```
- Verify installation:
  ```bash
  docker version
  docker run --rm hello-world
  ```
- Security: review the convenience script before running it in sensitive environments.

## kubectl (Kubernetes CLI)

Install a stable `kubectl` binary:

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
kubectl version --client --short
```

## kind (Kubernetes IN Docker)

Install a released `kind` binary and create a cluster:

```bash
curl -Lo ./kind "https://kind.sigs.k8s.io/dl/v0.20.0/kind-linux-amd64"
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
kind --version

# Create cluster
kind create cluster --name kind
kubectl cluster-info --context kind-kind
```

Alternatives: `k3d` (choose depending on preference and environment).

## Minikube (alternative to kind)

Install Minikube and start a cluster:

```bash
# Linux
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
chmod +x minikube
sudo mv minikube /usr/local/bin/
minikube start --driver=docker
minikube status
```

Notes:
- Minikube runs a single-node cluster, useful if you prefer it to kind or k3d.
- When using Docker in WSL2, ensure Minikube uses a compatible driver (docker) or use a VM driver where appropriate.

## Helm (optional, recommended for package management)

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
helm version
```

## Azure CLI (optional, for Azure cloud resources)

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | bash
az version
az login
```

## AWS CLI (optional, for AWS cloud resources)

```bash
# Linux
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip
aws --version
```

## Terraform (optional, for Infrastructure as Code)

```bash
# Linux
wget https://releases.hashicorp.com/terraform/1.7.0/terraform_1.7.0_linux_amd64.zip
unzip terraform_1.7.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
rm terraform_1.7.0_linux_amd64.zip
terraform version
```

## Git + Editor

Install Git and a preferred editor/IDE (VS Code recommended):

```bash
sudo apt-get install -y git
# install VS Code or your chosen editor
```

## Notes about environments

- WSL2 users: Docker Desktop + WSL2 integration or a native Docker Engine in the WSL distro are recommended. `host.docker.internal` may behave differently; prefer explicit host IPs or port-forwards when needed.
- If you run Kubernetes in VMs or cloud, ensure necessary networking (endpoint reachability) between the provider controller pods and LocalStack.

---

## Automation (optional)

A helper script is available at `installation/scripts/install-deps.sh` to automate installs and run verifications. Features:
- Per-tool install: docker, kubectl, kind, minikube, helm, azure-cli, aws-cli, terraform
- `--all` installs all tools
- `--dry-run` shows actions without making changes
- `--verify` checks installed versions

Usage:

```bash
chmod +x installation/scripts/install-deps.sh
# dry run
./installation/scripts/install-deps.sh --dry-run --all
# actually install (requires sudo)
sudo ./installation/scripts/install-deps.sh --all
# verify installed tools
./installation/scripts/install-deps.sh --verify
```

The script is conservative and prompts before running critical steps.