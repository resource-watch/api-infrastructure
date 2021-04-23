terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.10.0"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.1"
    }
  }
  required_version = "0.13.3"
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  version     = "~> 2.1"
  config_path = "~/.kube/config"
}

provider "kubectl" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}