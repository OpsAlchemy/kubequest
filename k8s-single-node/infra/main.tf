resource "tls_private_key" "k8s_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key_pem" {
  filename        = "${path.module}/keys/id_rsa"
  content         = tls_private_key.k8s_ssh.private_key_pem
  file_permission = "0600"
}

resource "local_file" "public_key_openssh" {
  filename        = "${path.module}/keys/id_rsa.pub"
  content         = tls_private_key.k8s_ssh.public_key_openssh
  file_permission = "0644"
}

resource "digitalocean_ssh_key" "k8s_key" {
  name       = "k8s-key-generated"
  public_key = tls_private_key.k8s_ssh.public_key_openssh
}

resource "digitalocean_droplet" "k8s_node" {
  name     = "k8s-single-node"
  region   = "blr1"
  size     = "s-4vcpu-8gb"
  image    = "ubuntu-22-04-x64"
  ssh_keys = [digitalocean_ssh_key.k8s_key.fingerprint]
  tags     = ["k8s", "terraform", "secure"]
}

resource "digitalocean_project_resources" "name" {
  project = data.digitalocean_project.k8s.id
  resources = [
    digitalocean_droplet.k8s_node.urn,
  ]
}

# output.tf 
output "droplet_ip" {
  value = digitalocean_droplet.k8s_node.ipv4_address
}

output "ssh_private_key_path" {
  value     = local_file.private_key_pem.filename
  sensitive = true
}
