terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.16.1"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.48.0"
    }
  }
  required_version = "1.3.6"
}

provider "aws" {
  region = var.aws_region
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}
