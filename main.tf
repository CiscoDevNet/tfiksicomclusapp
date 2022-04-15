#Helm install of sample app on IKS
data "terraform_remote_state" "iksws" {
  backend = "remote"
  config = {
    organization = var.org
    workspaces = {
      name = var.ikswsname
    }
  }
}

variable "org" {
  type = string
}
variable "ikswsname" {
  type = string
}

resource helm_release helloiksfrtfcb {
  name       = "helloiksapp"
  namespace = "default"
  chart = "https://prathjan.github.io/helm-chart/helloiks-0.1.1.tgz"

  set {
    name  = "MESSAGE"
    value = "Hello IKS from TFCB!!"
  }
}

provider "helm" {
  kubernetes {
    host = local.kube_config.clusters[0].cluster.server
    client_certificate = local.kube_config.users[0].user.client-certificate-data
    client_key = local.kube_config.users[0].user.client-key-data
    cluster_ca_certificate = local.kube_config.clusters[0].cluster.certificate-authority-data
  }
}

output "host" {
   value = local.host
}

locals {
  kube_config = yamldecode(base64decode(data.terraform_remote_state.iksws.outputs.kube_config))
    host = yamldecode(base64decode(data.terraform_remote_state.iksws.outputs.kube_config)).clusters[0].cluster.server
#    client_certificate = local.kube_config.users[0].user.client-certificate-data
#    client_key = local.kube_config.users[0].user.client-key-data
#    cluster_ca_certificate = local.kube_config.clusters[0].cluster.certificate-authority-data
}

