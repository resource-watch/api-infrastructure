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

# Cloudflare provider, so we can manage DNS
provider "cloudflare" {
  version = "~> 2.0"
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
  user_data   = data.template_file.bastion_setup.rendered
  bastion_ami = data.aws_ami.latest-ubuntu-lts.id
  project     = local.project
  tags        = local.tags
  private_subnet_tags = {
    "kubernetes.io/cluster/${lower(replace(local.project, " ", "-"))}-k8s-cluster-${var.environment}" : "shared"
    "kubernetes.io/role/internal-elb" : 1
  }
  public_subnet_tags = {
    "kubernetes.io/cluster/${lower(replace(local.project, " ", "-"))}-k8s-cluster-${var.environment}" : "shared"
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
    module.vpc.private_subnets[5].id
  ]
}

# Node groups for Mongodb server that serves the gateway app (control tower)
module "mongodb-gateway-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "mongodb-gateway-node-group"
  instance_types  = var.mongodb_gateway_node_group_instance_types
  min_size        = var.mongodb_gateway_node_group_min_size
  max_size        = var.mongodb_gateway_node_group_max_size
  desired_size    = var.mongodb_gateway_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
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
  instance_types  = var.gateway_node_group_instance_types
  min_size        = var.gateway_node_group_min_size
  max_size        = var.gateway_node_group_max_size
  desired_size    = var.gateway_node_group_desired_size
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

module "elasticsearch-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "elasticsearch-node-group"
  instance_types  = var.elasticsearch_node_group_instance_types
  min_size        = var.elasticsearch_node_group_min_size
  max_size        = var.elasticsearch_node_group_max_size
  desired_size    = var.elasticsearch_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id
  ]
  labels = {
    type : "elasticsearch"
  }
}

module "mongodb-apps-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "mongodb-apps-node-group"
  instance_types  = var.mongodb_apps_node_group_instance_types
  min_size        = var.mongodb_apps_node_group_min_size
  max_size        = var.mongodb_apps_node_group_max_size
  desired_size    = var.mongodb_apps_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id
  ]
  labels = {
    type : "mongodb-apps"
  }
}

module "apps-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "apps-node-group"
  instance_types  = var.apps_node_group_instance_types
  min_size        = var.apps_node_group_min_size
  max_size        = var.apps_node_group_max_size
  desired_size    = var.apps_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "apps"
  }
}

module "webapps-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "webapps-node-group"
  instance_types  = var.webapps_node_group_instance_types
  min_size        = var.webapps_node_group_min_size
  max_size        = var.webapps_node_group_max_size
  desired_size    = var.webapps_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "webapps"
  }
}

module "core-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "core-node-group"
  instance_types  = var.core_node_group_instance_types
  min_size        = var.core_node_group_min_size
  max_size        = var.core_node_group_max_size
  desired_size    = var.core_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "core"
  }
}

module "gfw-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "gfw-node-group"
  instance_types  = var.gfw_node_group_instance_types
  min_size        = var.gfw_node_group_min_size
  max_size        = var.gfw_node_group_max_size
  desired_size    = var.gfw_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "gfw"
  }
}

module "gfw-pro-node-group" {
  source          = "./modules/node_group"
  cluster         = module.eks.cluster
  cluster_name    = module.eks.cluster_name
  node_group_name = "gfw-pro-node-group"
  instance_types  = var.gfw_pro_node_group_instance_types
  min_size        = var.gfw_pro_node_group_min_size
  max_size        = var.gfw_pro_node_group_max_size
  desired_size    = var.gfw_pro_node_group_desired_size
  node_role_arn   = module.eks.node_role_arn
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "gfw-pro"
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
  source                    = "./modules/jenkins"
  jenkins_ami               = data.aws_ami.latest-ubuntu-lts.id
  vpc_id                    = module.vpc.id
  project                   = local.project
  subnet_id                 = module.vpc.public_subnets[0].id
  security_group_ids        = [aws_security_group.default.id]
  user_data                 = data.template_file.jenkins_config_on_ubuntu.rendered
  iam_instance_profile_role = module.vpc.eks_manager_role
  enabled                   = var.deploy_jenkins
}

data "cloudflare_zones" "resourcewatch" {
  filter {
    name   = "resourcewatch.org"
    status = "active"
    paused = false
  }
}

# Add a DNS record for Jenkins
resource "cloudflare_record" "jenkins_dns" {
  count = var.deploy_jenkins == "true" ? 1 : 0

  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = "jenkins.${var.dns_prefix}"
  value   = module.jenkins.jenkins_hostname
  type    = "CNAME"
  ttl     = 120
}

# Add a DNS record for bastion
resource "cloudflare_record" "bastion_dns" {
  zone_id = data.cloudflare_zones.resourcewatch.zones[0].id
  name    = "bastion.${var.dns_prefix}"
  value   = module.vpc.bastion_hostname
  type    = "CNAME"
  ttl     = 120
}