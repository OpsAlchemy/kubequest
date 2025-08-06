resource "kubernetes_pod" "this" {
   metadata {
     name = "terraform-pod"
   }
   
   spec {
     container {
       image = "nginx:1.21.6"
       name = "example"
       
       env {
         name = "environment"
         value = "test"
       }
         
       port {
         container_port = 80
       }
     }   
   }
}
