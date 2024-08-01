locals { 
  loki_workspace = terraform.workspace 

  loki_values = {
    web-cluster = {
      grafana_ing = {
        setname_ini_domain  = "grafana.grafana\\.ini.server.domain" 
        setvalue_ini_domain = "192.168.56.101:30232" 

        setname_ini_root_url  = "grafana.grafana\\.ini.server.root_url"
        setvalue_ini_root_url = "http://192.168.56.101:30232/loki"

        setname_ini_sub_path  = "grafana.grafana\\.ini.server.serve_from_sub_path"
        setvalue_ini_sub_path = replace("true", "\"", "")  
      }
    }
    was-cluster = {
      grafana_ing = {
        setname_ini_domain  = "grafana.grafana\\.ini.server.domain" 
        setvalue_ini_domain = "192.168.56.101:30232" 

        setname_ini_root_url  = "grafana.grafana\\.ini.server.root_url"
        setvalue_ini_root_url = "http://192.168.58.101:31545/loki"

        setname_ini_sub_path  = "grafana.grafana\\.ini.server.serve_from_sub_path"
        setvalue_ini_sub_path = replace("true", "\"", "")  
      }
    }
  }[local.loki_workspace] 
}

variable "loki_values" {
  description  = "Values for the ingress release"
  type         = map(any)
  default      = {}
}

resource "kubernetes_namespace" "loki_ns" {
  metadata {
    annotations = {
      name = "loki-stack"
    }
    labels = {
      role = "loki-stack"
    }
    name = "loki-stack"
  }
}

resource "helm_release" "loki-stack" {
  depends_on = [
    kubernetes_namespace.loki_ns 
  ]

  #repository    = "https://grafana.github.io/helm-charts"
  repository     = "./helm/"
  chart          = "loki-stack"
  version        = "2.10.2"
  name           = "loki-name"
  namespace      = kubernetes_namespace.loki_ns.metadata[0].name

  values = [
    file("./helm/loki-stack/values.yaml") 
  ]

  set {
    name  = "grafana.enabled"
    value = true 
  }
  set {
    name  = "grafana.sidecar.datasources.maxLines"
    value = 2000
  }
  set {
    name  = local.loki_values.grafana_ing.setname_ini_domain
    value = local.loki_values.grafana_ing.setvalue_ini_domain
  }
    set {
    name   = local.loki_values.grafana_ing.setname_ini_root_url
    value  = local.loki_values.grafana_ing.setvalue_ini_root_url  
  }
  set {
    name   = local.loki_values.grafana_ing.setname_ini_sub_path
    value  = local.loki_values.grafana_ing.setvalue_ini_sub_path
  }
}

resource "kubernetes_ingress_v1" "loki-ingress" {
  metadata {
    name      = "loki-ingress"
    namespace = kubernetes_namespace.loki_ns.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "nginx"
    }
  }

#  spec {
#    rule {
#      http {
#        path {
#          path     = "/loki"
#          #path_type = "Prefix"
#          backend {
#            service_name = "loki-name-grafana"
#            service_port = 3000
#          }
#        }
#      }
#    }
#  }

  spec {
    ingress_class_name = "nginx"
    rule {
      http {
        path {
          path     = "/loki"
          #path_type = "Prefix"
          backend {
            service {
              name = "loki-name-grafana"
              port {
                number = 3000
              }
            }
          }
        }
      }
    }
  }
}
