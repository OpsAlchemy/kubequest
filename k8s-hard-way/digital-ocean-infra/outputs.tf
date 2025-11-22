output "master_public_ip" {
  value = digitalocean_droplet.master["master"].ipv4_address
}

output "worker_public_ip" {
  value = digitalocean_droplet.master["worker"].ipv4_address
}

