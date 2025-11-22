locals {
  ssh_dir     = "${path.module}/keys"
  private_key = "${local.ssh_dir}/id_rsa"
  public_key  = "${local.ssh_dir}/id_rsa.pub"
  vm_specs = {
    "master" = "s-2vcpu-2gb"
    "worker" = "s-2vcpu-2gb"
  }
}

