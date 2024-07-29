locals { 
  workspace = terraform.workspace 
  
  namespace = {
    web-cluster    = "prometheus"
    was-cluster    = "prometheus"

  }[local.workspace]

  chart_values = {
    web-cluster = {
      grafana = {
        name    = "grafana.enabled" 
        value   = replace("true", "\"", "")
      }
    }
    was-cluster = {
      grafana = {
        name   = "grafana.enabled" 
        value  = replace("false", "\"", "")
      }
    }
  }[local.workspace] 
}

variable "namespace" {
  description  = "Namespace for the release"
  type         = string
}

variable "chart_values" {
  description  = "Values for the prometheus release"
  type         = map(any)
  default      = {}

}

resource "kubernetes_namespace" "prometheus_ns" {
  metadata {
    annotations = {
      name = local.namespace 
    }
    labels = {
      role = local.namespace
    }
    name = local.namespace
  }
}


resource "helm_release" "prometheus" {
  depends_on = [
    kubernetes_namespace.prometheus_ns
  ]
  
  #repository   = "https://https://prometheus-community.github.io/helm-charts"
  repository    = "./helm/"
  chart         = "kube-prometheus-stack"
  version       = "61.3.2"
  name          = "prometheus"
  namespace     = kubernetes_namespace.prometheus_ns.metadata[0].name 

  recreate_pods  = true

  values = [
    file("./helm/kube-prometheus-stack/values.yaml") 
  ]

  set {
    name   = local.chart_values.grafana.name
    value  = local.chart_values.grafana.value

  }

}

