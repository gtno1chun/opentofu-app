/*
resource "kubernetes_namespace" "metrics-server_ns"  {
  metadata {
    annotations = {
      name = "OOO"
    }
    labels = {
      role = "OOO"
    }
    name = "OOO"
  }
}
*/

resource "helm_release" "metrics-server" {

  #repository    = "https://kubernetes-sigs.github.io/metrics-server/"
  repository    = "./helm" 
  chart         = "metrics-server" 
  version       = "3.12.1" 
  name          = "metrics-server" 
  namespace     = "kube-system"
  
  recreate_pods = true
  
  values = [ 
    file("./helm/metrics-server/values.yaml")
  ]

  set_list {
    name  = "args" 
    value = ["--kubelet-insecure-tls"]
  }

}

