terraform {
  required_version = "~> 1.3"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48"
    }

    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.14.0"
    }
  }
}