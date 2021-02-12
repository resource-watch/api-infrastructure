terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "~> 1.9.4"
    }
  }
  required_version = "0.13.3"
}

provider "aws" {
  region = var.aws_region
}