# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    region         = "us-east-1"
    key            = "k8s-infrastructure.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

provider "aws" {
  region  = "us-east-1"
  version = "~> 3.0.0"
}



data "aws_eks_cluster" "rw_api" {
  name = "${replace(local.project, " ", "-")}-k8s-cluster-${var.environment}"
}

data "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "k8s_namespaces" {
  source = "./modules/k8s_namespaces"
}

module "k8s_infrastructure" {
  source           = "./modules/k8s_infrastructure"
  cluster_endpoint = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca       = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name     = data.aws_eks_cluster.rw_api.name
  aws_region       = var.aws_region
  vpc_id           = data.aws_vpc.eks_vpc.id
}

module "k8s_data_layer" {
  source                  = "./modules/k8s_data_layer"
  cluster_endpoint        = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca              = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name            = data.aws_eks_cluster.rw_api.name
  aws_region              = var.aws_region
  vpc_id                  = data.aws_vpc.eks_vpc.id
  elasticsearch_disk_size = var.elasticsearch_disk_size
}

module "k8s_core_services" {
  source      = "./modules/k8s_core_services"
  environment = var.environment
  dns_prefix  = var.dns_prefix
}

resource "aws_cognito_user_pool" "rw_api_user_pool" {
  name = "RW API user pool"
  username_attributes = ["email"]

  username_configuration {
    case_sensitive = false
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "role"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 256
    }
  }

  schema {
    attribute_data_type      = "String"
    developer_only_attribute = false
    mutable                  = true
    name                     = "extraUserData"
    required                 = true

    string_attribute_constraints {
      min_length = 1
      max_length = 1024
    }
  }
}