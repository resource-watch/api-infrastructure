terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    cloudflare = {
      source  = "terraform-providers/cloudflare"
      version = "~> 2.0"
    }
    template = {
      source = "hashicorp/template"
    }
  }
  required_version = "0.13.3"
}

provider "aws" {
  region = var.aws_region
}
