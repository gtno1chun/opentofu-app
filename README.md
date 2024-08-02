# OpenToFu를 이용한 어플리케이션 자동 설치 
참조 사이트 : https://opentofu.org/docs/


환경 
```
OS: Ubuntu 20.04
```

## 1. OpenToFu 설치 
```
참조 : https://opentofu.org/docs/intro/install/ 
$ sudo snap install --classic opentofu 
$ tofu -install-autocomplete
# restart bash 
```
## 2. Helm 설치 
```
$ sudo snap install --classic helm
```

## 3. OpenToFu 기본 사용 법 
```
$ tofu init
$ tofu plan
$ tofu apply
```

## 4. 현재 구성 
```
# tofu workspace 
tofu workspace :
  default   
  web-cluster  
  was-cluster

# kubernetes
dsi3@dsi3-k8s:~/works$ k config get-contexts
CURRENT   NAME                CLUSTER       AUTHINFO    NAMESPACE
          was-admin@cluster   was-cluster   was-admin
*         web-admin@cluster   web-cluster   web-admin
```
```
# workspec 생성
$ tofu workspace new [생성할 workspace 명]

# workspec 조회
$ tofu workspace list

# workspace 변경
$ tofu workspace select [변경할 workspace 명]
```

## 5. main.tf 
```
locals {
  k8s_context = "${terraform.workspace}"
  k8s_context_resolved = local.k8s_context == "web-cluster" ? "web-admin@cluster" : (
    local.k8s_context == "was-cluster" ? "was-admin@cluster" : local.k8s_context
  )
}
/* dev cluster 추가할 때
locals {
  k8s_context = "${terraform.workspace}"
  k8s_context_resolved = local.k8s_context == "web-cluster" ? "web-admin@cluster" : (
    local.k8s_context == "was-cluster" ? "was-admin@cluster" : (
      local.k8s_context == "dev-cluster" ? "dev-admin@cluster" : local.k8s_context
    )
  )
}
*/


# kubernetes provider
provider "kubernetes" {
  config_path     = "~/.kube/config"
  config_context   = local.k8s_context_resolved 
}

# Helm provider
provider "helm" {
  kubernetes {
    config_path     = "~/.kube/config"
    config_context   = local.k8s_context_resolved 
  }
}
```
