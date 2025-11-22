resource "tls_private_key" "this" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "local_file" "private_key" {
  content = tls_private_key.this.private_key_pem
  filename = local.private_key
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content = tls_private_key.this.public_key_openssh
  filename = local.public_key
}

resource "digitalocean_ssh_key" "this" {
  name = "master-ssh-key"
  public_key = tls_private_key.this.public_key_openssh
}

resource "digitalocean_vpc" "this" {
  name = "k8s-vpc"
  region = var.region
  ip_range = var.vpc_cidr
}

resource "digitalocean_droplet" "master" {
  for_each = local.vm_specs
  name = each.key
  size = each.value
  region = var.region
  image = "ubuntu-24-10-x64"
  vpc_uuid = digitalocean_vpc.this.id
  ssh_keys = [digitalocean_ssh_key.this.id]
}
