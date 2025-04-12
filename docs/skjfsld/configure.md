
---

# 🧰 Environment Setup Commands

This guide provides all necessary commands to prepare your local system for running VirtualBox, Vagrant, and provisioning infrastructure using DigitalOcean and Terraform.

---

## 🖥️ 1. Check Available Droplet Sizes (Optional)

Before provisioning, explore available droplet sizes on DigitalOcean using `doctl`:

```bash
doctl compute size list
```

For a cleaner output format:

```bash
doctl compute size list --format Slug,Description,Memory,Disk
```

---

## ⚙️ 2. Install Required Packages

Install essential tools, headers, and libraries needed for building modules and working with VirtualBox and Vagrant:

```bash
sudo apt install -y build-essential dkms linux-headers-$(uname -r) \
curl wget gnupg2 software-properties-common
```

---

## 🧱 3. Install VirtualBox (v7.1.6)

Download and install the appropriate `.deb` package:

```bash
wget https://download.virtualbox.org/virtualbox/7.1.6/virtualbox-7.1_7.1.6-167084~Ubuntu~jammy_amd64.deb
sudo apt install -y ./virtualbox-7.1_7.1.6-167084~Ubuntu~jammy_amd64.deb
```

---

## 📦 4. Install Vagrant

Add the official HashiCorp GPG key and repository:

```bash
wget -O - https://apt.releases.hashicorp.com/gpg | \
sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
```

Add the HashiCorp repository to your system:

```bash
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
sudo tee /etc/apt/sources.list.d/hashicorp.list
```

Update and install Vagrant:

```bash
sudo apt update && sudo apt install vagrant
```

---

## 🔁 5. Reboot and Final Configuration

After installing VirtualBox and Vagrant:

```bash
sudo reboot
```

Then, configure VirtualBox kernel modules:

```bash
sudo /sbin/vboxconfig
```