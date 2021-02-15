data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = var.kubectl_context
}

resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
  }
}