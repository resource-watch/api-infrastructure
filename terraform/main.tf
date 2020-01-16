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
  source             = "./modules/vpc"
  region             = var.aws_region
  user_data          = data.template_file.authorized_keys_ec2_user.rendered
  bastion_ami        = data.aws_ami.amazon_linux_ami.id
  project            = local.project
  tags               = local.tags
  subnet_tags        = {
    "kubernetes.io/cluster/${lower(replace(local.project, " ", "-"))}-k8s-cluster": "shared"
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
    module.vpc.private_subnets[5].id
  ]
}

# Create a k8s cluster using AWS EKS
module "node_group" {
  source          = "./modules/node_group"
  cluster_name    = module.eks.cluster_name
  node_group_name = "ct-node-group"
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
}
