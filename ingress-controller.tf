resource "kubernetes_namespace" "ingress-nginx_ns"  {
  metadata {
    annotations = {
      name = "ingress-nginx"
    }
    labels = {
      role = "ingress-nginx"
    }
    name = "ingress-nginx"
  }
}

resource "helm_release" "ingress-nginx" {
  depends_on = [
    kubernetes_namespace.ingress-nginx_ns
  ]

  #repository    = "https://kubernetes-sigs.github.io/metrics-server/"
  repository    = "./helm" 
  chart         = "ingress-nginx" 
  version       = "4.10.3" 
  name          = "ingress-nginx" 
  namespace     = kubernetes_namespace.ingress-nginx_ns.metadata[0].name
  
  # recreate_pods = true
  
  values = [ 
    file("./helm/ingress-nginx/values.yaml")
  ]

  set {
    name  = "controller.service.type"
    value = "NodePort"
  }
  set {
    name  = "controller.admissionWebhooks.failurePolicy"
    value = "Ignore"
  }

  set {
    name  = "controller.metrics.enabled"
    value = true 
  }
}

