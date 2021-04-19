data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  version = "~> 2.1"
}

provider "kubectl" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  version = "~> 1.2"

  kubernetes {
    host = var.cluster_endpoint

    cluster_ca_certificate = base64decode(var.cluster_ca)
  }
}