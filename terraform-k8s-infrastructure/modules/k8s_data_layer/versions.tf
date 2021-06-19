terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.36"
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
  version                = "~> 2.1"
  host                   = var.cluster_endpoint
  config_path            = "~/.kube/config"
  cluster_ca_certificate = base64decode(var.cluster_ca)
  exec {
    api_version = "client.authentication.k8s.io/v1alpha1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

provider "kubectl" {
  host                   = var.cluster_endpoint
  cluster_ca_certificate = base64decode(var.cluster_ca)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  version = "~> 2.0.2"

  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca)
    exec {
      api_version = "client.authentication.k8s.io/v1alpha1"
      args = [
        "eks",
        "get-token",
        "--cluster-name",
      var.cluster_name]
      command = "aws"
    }
  }
}