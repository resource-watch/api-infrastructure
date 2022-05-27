terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.44"
    }
    cloudflare = {
      source  = "terraform-providers/cloudflare"
      version = "~> 2.0"
    }
    sparkpost = {
      source  = "SurveyMonkey/sparkpost"
      version = "~> 0.2.1"
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

provider "sparkpost" {
  api_key = var.sparkpost_api_key

  # Sparkpost API url can be overridden to use the EU region
  base_url = "https://api.sparkpost.com"
}