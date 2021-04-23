terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
      aws = {
        source = "hashicorp/aws"
        version = "~> 3.0"
      }

      kubernetes = {
        source = "hashicorp/kubernetes"
        version = "~> 2.1"
      }
    }
    required_version = "0.13.3"
  }
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  version = "~> 2.1"
  config_path = "~/.kube/config"
}
