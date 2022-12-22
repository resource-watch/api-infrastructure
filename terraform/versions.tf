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
    sparkpost = {
      source  = "SurveyMonkey/sparkpost"
      version = "~> 0.2.2"
    }
    template = {
      source = "hashicorp/template"
      version = "~> 2.2.0"
    }
  }
  required_version = "1.3.6"
}

provider "aws" {
  region = var.aws_region
}

provider "sparkpost" {
  api_key = var.sparkpost_api_key

  # Sparkpost API url can be overridden to use the EU region
  base_url = "https://api.sparkpost.com"
}
