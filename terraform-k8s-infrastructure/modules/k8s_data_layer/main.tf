data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "helm" {
  version = "~> 1.2"

  kubernetes {
    host = var.cluster_endpoint

    cluster_ca_certificate = base64decode(var.cluster_ca)
  }
}