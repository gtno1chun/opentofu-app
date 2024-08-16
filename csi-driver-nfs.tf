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

resource "null_resource" "csi-driver-nfs-storageclass" {
  depends_on = [
    helm_release.csi-driver-nfs
  ]

  provisioner "local-exec" {
    command = "kubectl apply -f ./k8s_yaml/nfs_csi/csi-driver/storageclass-csi.yaml"
  }
}