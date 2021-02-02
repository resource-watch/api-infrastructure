data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  config_path    = "~/.kube/config"
  config_context = "aws-rw-dev"
  //  version = "~> 2.0.1"
  //  host                   = var.cluster_endpoint
  //  cluster_ca_certificate = base64decode(var.cluster_ca)
  //  exec {
  //    api_version = "client.authentication.k8s.io/v1alpha1"
  //    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  //    command     = "aws"
  //  }
}

resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
  }
}