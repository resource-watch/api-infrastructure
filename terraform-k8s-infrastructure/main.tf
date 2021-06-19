# Require TF version to be same as or greater than 0.12.13
terraform {
  backend "s3" {
    region         = "us-east-1"
    key            = "k8s-infrastructure.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

data "aws_eks_cluster" "rw_api" {
  name = "${replace(local.project, " ", "-")}-k8s-cluster-${var.environment}"
}

data "aws_vpc" "eks_vpc" {
  cidr_block = "10.0.0.0/16"
}

module "k8s_infrastructure" {
  source                = "./modules/k8s_infrastructure"
  cluster_endpoint      = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca            = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name          = data.aws_eks_cluster.rw_api.name
  aws_region            = var.aws_region
  vpc_id                = data.aws_vpc.eks_vpc.id
  deploy_metrics_server = var.deploy_metrics_server
}

module "k8s_data_layer" {
  source                                   = "./modules/k8s_data_layer"
  cluster_endpoint                         = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca                               = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name                             = data.aws_eks_cluster.rw_api.name
  aws_region                               = var.aws_region
  vpc                                      = data.aws_vpc.eks_vpc
  elasticsearch_disk_size_gb               = var.elasticsearch_disk_size_gb
  elasticsearch_use_dedicated_master_nodes = var.elasticsearch_use_dedicated_master_nodes
  elasticsearch_data_nodes_count           = var.elasticsearch_data_nodes_count
  backups_bucket                           = var.backups_bucket
  elasticsearch_data_nodes_type            = var.elasticsearch_data_nodes_type
}

module "k8s_microservice_routing" {
  source               = "./modules/k8s_microservice_routing"
  environment          = var.environment
  dns_prefix           = var.dns_prefix
  vpc                  = data.aws_vpc.eks_vpc
  cluster_endpoint     = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca           = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name         = data.aws_eks_cluster.rw_api.name
  tf_core_state_bucket = var.tf_core_state_bucket
  x_rw_domain          = var.x_rw_domain
}

module "k8s_namespaces" {
  source           = "./modules/k8s_namespaces"
  cluster_endpoint = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca       = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name     = data.aws_eks_cluster.rw_api.name
  kubectl_context  = "aws-rw-${var.environment}"
  namespaces       = var.namespaces
}