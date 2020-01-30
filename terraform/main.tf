# Require TF version to be same as or greater than 0.12.13
terraform {
  required_version = ">=0.12.13"
  backend "s3" {
    region         = "us-east-1"
    key            = "core.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# Download any stable version in AWS provider of 2.36.0 or higher in 2.36 train
provider "aws" {
  region  = "us-east-1"
  version = "~> 2.38.0"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}

# Internal module which defines the VPC
module "vpc" {
  source      = "./modules/vpc"
  region      = var.aws_region
  user_data   = data.template_file.authorized_keys_ec2_user.rendered
  bastion_ami = data.aws_ami.amazon_linux_ami.id
  project     = local.project
  tags        = local.tags
  private_subnet_tags = {
    "kubernetes.io/cluster/${lower(replace(local.project, " ", "-"))}-k8s-cluster" : "shared"
    "kubernetes.io/role/internal-elb" : 1
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${lower(replace(local.project, " ", "-"))}-k8s-cluster" : "shared"
    "kubernetes.io/role/elb" : 1
  }
  security_group_ids = [aws_security_group.default.id]
}

# Create a k8s cluster using AWS EKS
module "eks" {
  source      = "./modules/eks"
  project     = local.project
  vpc_id      = module.vpc.id
  environment = var.environment
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id,
    module.vpc.public_subnets[0].id,
    module.vpc.public_subnets[1].id,
    module.vpc.public_subnets[2].id,
    module.vpc.public_subnets[3].id,
    module.vpc.public_subnets[5].id
  ]
}

# Node groups for Mongodb server that serves the gateway app (control tower)
module "mongodb-gateway-node-group-az1" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "mongodb-gateway-node-group-az1"
  instance_types  = "m5a.large"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id
  ]
  labels = {
    type : "mongodb-gateway"
  }
}

module "mongodb-gateway-node-group-az2" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "mongodb-gateway-node-group-az2"
  instance_types  = "m5a.large"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[1].id
  ]
  labels = {
    type : "mongodb-gateway"
  }
}

module "mongodb-gateway-node-group-az3" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "mongodb-gateway-node-group-az3"
  instance_types  = "m5a.large"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[2].id
  ]
  labels = {
    type : "mongodb-gateway"
  }
}

module "gateway-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "gateway-node-group"
  instance_types  = "m5a.large"
  min_size        = 2
  max_size        = 4
  desired_size    = 3
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "gateway"
  }
}

module "elasticsearch-node-group-az1" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "elasticsearch-node-group-az1"
  instance_types  = "m5a.xlarge"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[1].id
  ]
  labels = {
    type : "elasticsearch"
  }
}

module "elasticsearch-node-group-az2" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "elasticsearch-node-group-az2"
  instance_types  = "m5a.xlarge"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[1].id
  ]
  labels = {
    type : "elasticsearch"
  }
}

module "elasticsearch-node-group-az3" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "elasticsearch-node-group-az3"
  instance_types  = "m5a.xlarge"
  min_size        = 1
  max_size        = 1
  desired_size    = 1
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[2].id
  ]
  labels = {
    type : "elasticsearch"
  }
}

resource "aws_acm_certificate" "aws-dev-resourcewatch-org-certificate" {
  domain_name       = "${var.dns_prefix}.resourcewatch.org"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

module "jenkins" {
  source             = "./modules/jenkins"
  jenkins_ami        = data.aws_ami.latest-ubuntu-lts.id
  vpc_id             = module.vpc.id
  project            = local.project
  subnet_id          = module.vpc.public_subnets[0].id
  security_group_ids = [aws_security_group.default.id]
  user_data          = data.template_file.jenkins_config_on_ubuntu.rendered
}
