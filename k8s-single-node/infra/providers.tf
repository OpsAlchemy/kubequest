terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }

  // export these
  // export AWS_ACCESS_KEY_ID="DO008MCEP2QL3BKABFM9"
  // export AWS_SECRET_ACCESS_KEY="yDQowk5n+TkjubffF2r/iCaunLm+HDrCVwp8BfZo0Gc"

  backend "s3" {
    endpoints = {
      s3 = "https://blr1.digitaloceanspaces.com"
    }
    bucket                      = "k8s-infra-terraform-bucket-01"
    key                         = "k8s/single-node/terraform.tfstate"
    region                      = "blr1"
    skip_credentials_validation = true
    skip_requesting_account_id  = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_s3_checksum            = true
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
