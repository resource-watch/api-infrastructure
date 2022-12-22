terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
  }
  required_version = "~> 1.3.2"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
