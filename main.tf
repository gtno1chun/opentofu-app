locals {
  k8s_context = "${terraform.workspace}"
  k8s_context_resolved = local.k8s_context == "web-cluster" ? "web-admin@cluster" : (
    local.k8s_context == "was-cluster" ? "was-admin@cluster" : local.k8s_context
  )
}

# kubernetes provider
provider "kubernetes" {
  config_path     = "~/.kube/config"
  config_context   = local.k8s_context_resolved 
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path     = "~/.kube/config"
    config_context   = local.k8s_context_resolved 
  }
} 

/*
resource "null_resource" "kubectl_command" {
  provisioner "local-exec" {
    command = "kubectl --context=${local.k8s_context_resolved} get nodes"
  }
}
*/

output "k8s_context" {
  value = local.k8s_context_resolved 

}

