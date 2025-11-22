variable "do_token" {
  description = "DigitalOcean API token"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "DigitalOcean region"
  type        = string
  default     = "nyc1"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.20.0.0/16"
}

variable "droplet_name" {
  default = "k8s-control-plane"
}

variable "droplet_size" {
  default = "s-2vcpu-2gb"
}

variable "droplet_image" {
  default = "ubuntu-24-10-x64"
}
