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
  source           = "./modules/k8s_infrastructure"
  cluster_endpoint = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca       = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name     = data.aws_eks_cluster.rw_api.name
  aws_region       = var.aws_region
  vpc_id           = data.aws_vpc.eks_vpc.id
}

module "k8s_data_layer" {
  source                     = "./modules/k8s_data_layer"
  cluster_endpoint           = "${data.aws_eks_cluster.rw_api.endpoint}:4433"
  cluster_ca                 = data.aws_eks_cluster.rw_api.certificate_authority.0.data
  cluster_name               = data.aws_eks_cluster.rw_api.name
  aws_region                 = var.aws_region
  vpc                        = data.aws_vpc.eks_vpc
  elasticsearch_disk_size    = var.elasticsearch_disk_size
  elasticsearch_disk_size_gb = var.elasticsearch_disk_size_gb
  backups_bucket             = var.backups_bucket
}

module "k8s_namespaces" {
  source = "./modules/k8s_namespaces"
}