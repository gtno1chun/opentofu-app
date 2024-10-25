## change value 참조 : ./helm/jenkins/README.md

resource "kubernetes_namespace" "jenkins_ns" {
  count = terraform.workspace == "was-cluster" ? 1 : 0 

  metadata {
    annotations = {
      name = "jenkins"
    }
    labels = {
      role = "jenkins"
    }
    name = "jenkins"
  }
}

resource "helm_release" "jenkins" {
  count = terraform.workspace == "was-cluster" ? 1 : 0 
  depends_on = [
    kubernetes_namespace.jenkins_ns,
    helm_release.csi-driver-nfs
  ]

  repository      = "./helm/"
  chart           = "jenkins"
  version         = "5.5.9"
  name            = "jenkins"
  namespace       = length(kubernetes_namespace.jenkins_ns) > 0 ? kubernetes_namespace.jenkins_ns[0].metadata[0].name : "" 

  values = [
    file("./helm/jenkins/values.yaml") 
  ]
}
