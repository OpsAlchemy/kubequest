Got it! Here's the cleaned-up and properly formatted content for `docs/index.md` — **without the markdown code block wrapper**:

---

# KubeQuest: Dev Environment Overview

## 🎯 Project Objective

**KubeQuest** is a developer-focused environment designed to provision cloud infrastructure on **DigitalOcean droplets** and configure **Kubernetes from scratch**, following and expanding on the principles of **"Kubernetes the Hard Way"**.

It enables experimentation with different Kubernetes setups and automation strategies using tools like **Terraform**, **Vagrant**, and **VirtualBox**.

---

## 🛠️ Goals

- Provide a repeatable, modular Terraform setup for provisioning infrastructure  
- Implement Kubernetes the Hard Way with flexibility and customization  
- Support both cloud (DigitalOcean, Azure) and local (VirtualBox) environments  
- Explore Kubernetes bootstrapping, networking, and certificate management  
- Maintain a clear structure for scripting, tooling, and documentation  

---

## 🚀 Setup Workflow

### 1. Keeper Infrastructure (`global/keeper`)
- Terraform configuration for global resources and shared variables  
- Serves as the base layer before provisioning any Kubernetes nodes  

### 2. Single Node Kubernetes Infra (`k8s-single-node/infra`)
- Uses Terraform to spin up a droplet (e.g., on DigitalOcean)  
- SSH keys are generated and managed here  
- Includes a `k8s-single-node.sh` script to automate node provisioning  

### 3. Manual or Scripted Kubernetes Configuration
- Based on the Kubernetes the Hard Way approach  
- Scripts and docs included for:
  - TLS bootstrapping
  - kubelet setup
  - Pod networking
  - Control plane configuration

---

## 🗂️ Project Structure

```
project-root/
├── global/keeper/                  # Base infrastructure (Terraform)
├── k8s-single-node/infra/         # Single-node provisioning setup
├── references/kubernetes-the-hard-way/  # Modified KTHW scripts & docs
├── modules/                        # Provider-specific Terraform modules
├── docs/                           # Documentation (this file)
└── utils/                          # Utility scripts
```

---

## 📘 Getting Started

1. Set up your local system and required packages  
   → Refer to `docs/commands.md`  

2. Initialize and apply the keeper infrastructure:
   ```bash
   cd global/keeper
   terraform init
   terraform apply
   ```

3. Spin up the single-node environment:
   ```bash
   cd k8s-single-node/infra
   terraform init
   terraform apply
   ```

4. SSH into the droplet and run the setup script:
   ```bash
   ./k8s-single-node.sh
   ```

---

## 📎 Notes

- This is a developer-focused environment, **not production ready**  
- Designed for experimentation, learning, and customization  
- Feel free to extend with additional modules, clusters, or providers  

---

Happy Hacking 🚀

---

Let me know when you're ready to write `commands.md` — I’ll format it just as cleanly.