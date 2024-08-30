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
      prometheus_name = {
        name    = "nameOverride"
        value   = "prom-web"
      }
    }
    was-cluster = {
      grafana = {
        name   = "grafana.enabled" 
        value  = replace("false", "\"", "")
      }
      prometheus_name = {
        name    = "nameOverride"
        value   = "prom-was"
      }

    }
  }[local.workspace] 

  ingress_values = {
    web-cluster = {
      grafana_ing = {
        setname_enabled  = "grafana.ingress.enabled"
        setvalue_enabled = replace("true", "\"", "")
        
        setname_ing_class_name  = "grafana.ingress.ingressClassName" 
        setvalue_ing_class_name = "nginx"

        setname_path  = "grafana.ingress.path"
        setvalue_path = "/grafana" 

        setname_ini_domain  = "grafana.grafana\\.ini.server.domain" 
        setvalue_ini_domain = "192.168.56.101:30232" 

        setname_ini_root_url  = "grafana.grafana\\.ini.server.root_url"
        setvalue_ini_root_url = "http://192.168.56.101:30232/grafana"

        setname_ini_sub_path  = "grafana.grafana\\.ini.server.serve_from_sub_path"
        setvalue_ini_sub_path = replace("true", "\"", "")  
      }
      prometheus_ing = {
        setname_enabled  = "prometheus.ingress.enabled"
        setvalue_enabled = replace("true", "\"", "") 

        setname_ing_class_name  = "prometheus.ingress.ingressClassName"
        setvalue_ing_class_name = "nginx"

        setname_annotaion  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
        setvalue_annotaion = "/$2"

        setname_paths  = "prometheus.ingress.paths[0]"
        setvalue_paths = "/prom(/|$)(.*)"
      }
    }
    was-cluster = {
      grafana_ing = {
        setname_enabled  = "grafana.ingress.enabled"
        setvalue_enabled = replace("false", "\"", "")
        
        setname_ing_class_name  = "grafana.ingress.ingressClassName" 
        setvalue_ing_class_name = "nginx"

        setname_path  = "grafana.ingress.path"
        setvalue_path = "/grafana" 

        setname_ini_domain  = "grafana.grafana\\.ini.server.domain" 
        setvalue_ini_domain = "192.168.56.101:30232" 

        setname_ini_root_url  = "grafana.grafana\\.ini.server.root_url"
        setvalue_ini_root_url = "http://192.168.58.101:31545/grafana"

        setname_ini_sub_path  = "grafana.grafana\\.ini.server.serve_from_sub_path"
        setvalue_ini_sub_path = replace("true", "\"", "")  
      }
      prometheus_ing = {
        setname_enabled  = "prometheus.ingress.enabled"
        setvalue_enabled = replace("true", "\"", "") 

        setname_ing_class_name  = "prometheus.ingress.ingressClassName"
        setvalue_ing_class_name = "nginx"

        setname_annotaion  = "prometheus.ingress.annotations.nginx\\.ingress\\.kubernetes\\.io/rewrite-target"
        setvalue_annotaion = "/$2"

        setname_paths  = "prometheus.ingress.paths[0]"
        setvalue_paths = "/prom(/|$)(.*)"
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
variable "ingress_values" {
  description  = "Values for the ingress release"
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
    kubernetes_namespace.prometheus_ns,
    helm_release.csi-driver-nfs 
  ]
  
  #repository   = "https://prometheus-community.github.io/helm-charts"
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
    name   = local.chart_values.prometheus_name.name
    value  = local.chart_values.prometheus_name.value
  }
  set {
    name   = local.chart_values.grafana.name
    value  = local.chart_values.grafana.value
  }
 
  ## Setting Ingress for grafana 
  set {
    name   = local.ingress_values.grafana_ing.setname_enabled
    value  = local.ingress_values.grafana_ing.setvalue_enabled 
  }
  set {
    name   = local.ingress_values.grafana_ing.setname_ing_class_name
    value  = local.ingress_values.grafana_ing.setvalue_ing_class_name
  }
  set {
    name   = local.ingress_values.grafana_ing.setname_path
    value  = local.ingress_values.grafana_ing.setvalue_path
  }
  set {
    name   = local.ingress_values.grafana_ing.setname_ini_domain
    value  = local.ingress_values.grafana_ing.setvalue_ini_domain  
  }
  set {
    name   = local.ingress_values.grafana_ing.setname_ini_root_url
    value  = local.ingress_values.grafana_ing.setvalue_ini_root_url  
  }
  set {
    name   = local.ingress_values.grafana_ing.setname_ini_sub_path
    value  = local.ingress_values.grafana_ing.setvalue_ini_sub_path
  }

  ## Setting Ingress for grafana 
  ## valuse.yaml 4297 아래 설정 후 도메인/prom/graph 접속해야 함.
  set {
    name  = local.ingress_values.prometheus_ing.setname_enabled
    value = local.ingress_values.prometheus_ing.setvalue_enabled
  }
  set {
    name  = local.ingress_values.prometheus_ing.setname_ing_class_name
    value = local.ingress_values.prometheus_ing.setvalue_ing_class_name
  }
  set {
    name  = local.ingress_values.prometheus_ing.setname_annotaion
    value = local.ingress_values.prometheus_ing.setvalue_annotaion
  }
  set {
    name  = local.ingress_values.prometheus_ing.setname_paths
    value = local.ingress_values.prometheus_ing.setvalue_paths 
  }

  # prometheus persistence volume
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.storageClassName"
    value = "csi-nfs-sc" 
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.accessModes[0]"
    value = "ReadWriteOnce" 
  }
  set {
    name  = "prometheus.prometheusSpec.storageSpec.volumeClaimTemplate.spec.resources.requests.storage"
    value = "50Gi" 
  }

  # if grafana false 실행되지 않음
  set {
    name  = "grafana.persistence.enabled"
    value = true 
  } 
  set {
    name  = "grafana.persistence.type"
    value = "sts"
  }
  set {
    name  = "grafana.persistence.storageClassName"
    value = "csi-nfs-sc" 
  }
  set {
    name  = "grafana.persistence.accessModes[0]"
    value = "ReadWriteOnce" 
  }
  set {
    name  = "grafana.persistence.size"
    value = "20Gi" 
  }
  set {
    name  = "grafana.persistence.finalizers"
    value = "kubernetes.io/pvc-protection" 
  }

}
