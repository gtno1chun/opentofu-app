resource "helm_release" "csi-driver-nfs" {

  #repository    = "https://raw.githubusercontent.com/kubernetes-csi/csi-driver-nfs/master/charts"
  repository     = "./helm/"
  chart          = "csi-driver-nfs"
  version        = "v4.8.0"
  name           = "csi-driver-nfs"
  namespace      = "kube-system"

  values = [
    file("./helm/csi-driver-nfs/values.yaml") 
  ]

#  set {
#    name   = "storageClass.create"
#    value  = true
#  }
#  set {
#    name   = "storageClass.name"
#    value  = "csi-nfs-sc"
#  }
}

resource "null_resource" "csi-nfs-drive" {
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOC
      #kubectl get node --context=${local.k8s_context_resolved}
      kubectl apply -f ./k8s_yaml/nfs_csi/csi-driver/storageclass-csi.yaml --context=${local.k8s_context_resolved}
      kubectl get storageClass --context=${local.k8s_context_resolved}
    EOC
  }
}
