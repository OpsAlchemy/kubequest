terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "do_token" {
  default = "dop_v1_e06e98d1d6290b74707a0ae1a80891491e0112f91b44da4e4c11697cc1505bc6"
}
variable "spaces_access_id" {
  default = "DO008MCEP2QL3BKABFM9"
}
variable "spaces_secret_key" {
  default = "yDQowk5n+TkjubffF2r/iCaunLm+HDrCVwp8BfZo0Gc"
}
provider "digitalocean" {
  token             = var.do_token
  spaces_access_id  = var.spaces_access_id
  spaces_secret_key = var.spaces_secret_key
}


data "digitalocean_project" "k8s" {
  name = "k8s"
}



resource "digitalocean_spaces_bucket" "tf_state" {
  name   = "k8s-infra-terraform-bucket-01"
  region = "blr1"
  versioning {
    enabled = true
  }
}


resource "digitalocean_project_resources" "k8s" {
  project = data.digitalocean_project.k8s.id
  resources = [
    digitalocean_spaces_bucket.tf_state.urn
  ]
}
