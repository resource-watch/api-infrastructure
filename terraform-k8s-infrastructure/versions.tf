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

provider "cloudflare" {
  api_key = var.cloudflare_api_key
  email   = var.cloudflare_email
}

data "aws_eks_cluster_auth" "cluster" {
  name = data.aws_eks_cluster.rw_api.name
}

provider "kubernetes" {
  host                    = "${data.aws_eks_cluster.rw_api.endpoint}:${var.cluster_port}"
  #config_path            = "~/.kube/config"
  cluster_ca_certificate  = base64decode(data.aws_eks_cluster.rw_api.certificate_authority.0.data)
  token                   = data.aws_eks_cluster_auth.cluster.token
  #exec {
  #  api_version = "client.authentication.k8s.io/v1beta1"
  #  args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  #  command     = "aws"
  #}
}

provider "kubectl" {
  host                   = "${data.aws_eks_cluster.rw_api.endpoint}:${var.cluster_port}"
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.rw_api.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
  load_config_file       = false
}

provider "helm" {
  kubernetes {
    host                   = "${data.aws_eks_cluster.rw_api.endpoint}:${var.cluster_port}"
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.rw_api.certificate_authority.0.data)
    token                  = data.aws_eks_cluster_auth.cluster.token
    #exec {
    #  api_version = "client.authentication.k8s.io/v1beta1"
    #  args = [
    #    "eks",
    #    "get-token",
    #    "--cluster-name",
    #    var.cluster_name
    #  ]
    #  command = "aws"
    #}
  }
}