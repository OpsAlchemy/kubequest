terraform {
 required_providers {
   kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.37.1"
   }
 }
}
provider "kubernetes" {
   config_path = "~/.kube/config"
   config_context = "aks-puregym-test-ukwest"
}

resource "kubernetes_namespace" "this" {
  metadata {
    name = "sample" 
  }
}
