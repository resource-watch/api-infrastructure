terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 3.30.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }
  required_version = "1.3.6"
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                    = var.cluster_endpoint
  #config_path            = "~/.kube/config"
  cluster_ca_certificate  = base64decode(var.cluster_ca)
  token                   = data.aws_eks_cluster_auth.cluster.token
  #exec {
  #  api_version = "client.authentication.k8s.io/v1beta1"
  #  args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  #  command     = "aws"
  #}
}