terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }

    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.8.0"
    }
  }
  required_version = "1.3.6"
}

provider "aws" {
  region = var.aws_region
}

provider "helm" {
  kubernetes {
    host                   = var.cluster_endpoint
    cluster_ca_certificate = base64decode(var.cluster_ca)
    exec {
<<<<<<< HEAD
      api_version = "client.authentication.k8s.io/v1beta1"
      args = [
=======
      api_version = "client.authentication.k8s.io/v1alpha1"
      args        = [
>>>>>>> 072f17c (WIP - API Gateway API keys)
        "eks",
        "get-token",
        "--cluster-name",
        var.cluster_name
      ]
      command = "aws"
    }
  }
}
