resource "null_resource" "cafe_test_app" {
  provisioner "local-exec" {
    command = "kubectl apply -f ./k8s_yaml/test_app/cafe.yaml"
  }
}

