#resource "random_pet" "dna_test_app_trigger" {}

resource "null_resource" "dna_test_app" {
  count = terraform.workspace == "dna_lab" ? 1 : 0
  
  triggers = {
    #always_run = random_pet.dna_test_app_trigger.id
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = <<EOF
      kubectl --context=${local.k8s_context_resolved} get nodes  
      kubectl --context=${local.k8s_context_resolved} apply -f ./k8s_yaml/test_app/test_dna_lab_cafe.yaml
      kubectl --context=${local.k8s_context_resolved} apply -f ./k8s_yaml/test_app/test_dna_lab_cafe_ingress.yaml
    EOF
  }
}

output "run_cluster_context" {
  value = local.k8s_context_resolved 
}