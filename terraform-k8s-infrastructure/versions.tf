terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.36"
    }
  }
  required_version = "0.13.3"
}

provider "aws" {
  region = var.aws_region
}