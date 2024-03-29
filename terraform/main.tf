# Require TF version to be same as or greater than 0.12.13
terraform {
  backend "s3" {
    region         = "us-east-1"
    key            = "core.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
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
  security_group_ids = [
    aws_security_group.default.id, aws_security_group.document_db.id, aws_security_group.postgresql.id
  ]

}

# Create a k8s cluster using AWS EKS
module "eks" {
  source                = "./modules/eks"
  project               = local.project
  vpc_id                = module.vpc.id
  environment           = var.environment
  backups_bucket        = var.backups_bucket
  eks_version           = var.eks_version
  aws_region            = var.aws_region
  ebs_csi_addon_version = var.ebs_csi_addon_version
  subnet_ids = [
    module.vpc.private_subnets[0].id,
    module.vpc.private_subnets[1].id,
    module.vpc.private_subnets[2].id,
    module.vpc.private_subnets[3].id,
    module.vpc.private_subnets[5].id
  ]
}

module "mongodb-apps-node-group" {
  count                    = var.hibernate ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "mongodb-apps-node-group"
  instance_types           = var.mongodb_apps_node_group_instance_types
  min_size                 = var.mongodb_apps_node_group_min_size
  max_size                 = var.mongodb_apps_node_group_max_size
  desired_size             = var.mongodb_apps_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = var.mongodb_apps_node_group_capacity_type
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
  count                    = var.hibernate ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "apps-node-group"
  instance_types           = var.apps_node_group_instance_types
  min_size                 = var.apps_node_group_min_size
  max_size                 = var.apps_node_group_max_size
  desired_size             = var.apps_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = var.apps_node_group_capacity_type
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
  count                    = var.hibernate ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "webapps-node-group"
  instance_types           = var.webapps_node_group_instance_types
  min_size                 = var.webapps_node_group_min_size
  max_size                 = var.webapps_node_group_max_size
  desired_size             = var.webapps_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = var.webapps_node_group_capacity_type
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
  count                    = var.hibernate ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "core-node-group"
  instance_types           = var.core_node_group_instance_types
  min_size                 = var.core_node_group_min_size
  max_size                 = var.core_node_group_max_size
  desired_size             = var.core_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = var.core_node_group_capacity_type
  subnet_ids = [
    module.vpc.private_subnets[5].id
  ]
  labels = {
    type : "core"
  }
}

module "gfw-node-group" {
  count                    = var.hibernate ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "gfw-node-group"
  instance_types           = var.gfw_node_group_instance_types
  min_size                 = var.gfw_node_group_min_size
  max_size                 = var.gfw_node_group_max_size
  desired_size             = var.gfw_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = var.gfw_node_group_capacity_type
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

module "gateway-node-group" {
  count                    = (var.gateway_node_group_desired_size == 0 || var.hibernate) ? 0 : 1
  source                   = "./modules/node_group"
  cluster                  = module.eks.cluster
  cluster_name             = module.eks.cluster_name
  node_group_name          = "gateway-node-group"
  instance_types           = var.gateway_node_group_instance_types
  min_size                 = var.gateway_node_group_min_size
  max_size                 = var.gateway_node_group_max_size
  desired_size             = var.gateway_node_group_desired_size
  node_role_arn            = module.eks.node_role_arn
  eks_node_release_version = var.eks_node_release_version
  capacity_type            = "ON_DEMAND"
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

module "documentdb" {
  source               = "./modules/document_db"
  log_retention_period = var.log_retention_period
  private_subnet_ids = [
    module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id, module.vpc.private_subnets[3].id
  ]
  project                         = local.project
  backup_retention_period         = var.backup_retention_period
  instance_class                  = var.db_instance_class
  cluster_size                    = var.db_instance_count
  master_username                 = "wri" # superuser, create app specific users at project level
  tags                            = local.tags
  vpc_id                          = module.vpc.id
  vpc_cidr_block                  = module.vpc.cidr_block
  engine_version                  = "3.6.0"
  enabled_cloudwatch_logs_exports = var.db_logs_exports
  cluster_parameters = [
    {
      apply_method = "pending-reboot"
      name         = "profiler"
      value        = "disabled"
    },
    {
      apply_method = "immediate"
      name         = "profiler_threshold_ms"
      value        = "50"
    },
    {
      apply_method = "pending-reboot"
      name         = "tls"
      value        = "disabled"
    }
  ]
}

module "postgresql" {
  source = "./modules/postgresql"
  availability_zone_names = [
    module.vpc.private_subnets[0].availability_zone, module.vpc.private_subnets[1].availability_zone,
    module.vpc.private_subnets[3].availability_zone
  ]
  log_retention_period = var.log_retention_period
  private_subnet_ids = [
    module.vpc.private_subnets[0].id, module.vpc.private_subnets[1].id, module.vpc.private_subnets[3].id
  ]
  project                     = local.project
  rds_backup_retention_period = var.backup_retention_period
  rds_engine_version          = var.rds_engine_version
  rds_db_name                 = "wri"      # default database, create app specific database at project level
  rds_user_name               = "postgres" # superuser, create app specific users at project level
  rds_instance_class          = var.rds_instance_class
  rds_instance_count          = var.rds_instance_count
  tags                        = local.tags
  vpc_id                      = module.vpc.id
  rds_port                    = 5432
  vpc_cidr_block              = module.vpc.cidr_block
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
}

module "email-templates" {
  count             = var.deploy_sparkpost_templates ? 1 : 0
  source            = "./modules/email-templates"
  sparkpost_api_key = var.sparkpost_api_key
}

module "cloudwatch-charts" {
  source = "./modules/cloudwatch-charts"
}

# module "eks_scaling" {
#   source                            = "./modules/eks_scaling"
#   eks_cluster_name                  = module.eks.cluster_name
#   apps_node_group_min_size          = var.apps_node_group_min_size
#   apps_node_group_max_size          = var.apps_node_group_max_size
#   apps_node_group_desired_size      = var.apps_node_group_max_size
#   apps_node_group_min_size_upscaled = var.apps_node_group_min_size_upscaled
#   gfw_node_group_min_size           = var.gfw_node_group_min_size
#   gfw_node_group_max_size           = var.gfw_node_group_max_size
#   gfw_node_group_desired_size       = var.gfw_node_group_max_size
#   gfw_node_group_min_size_upscaled  = var.gfw_node_group_min_size_upscaled
# }

module "aq_bucket" {
  source              = "./modules/aq_bucket"
  environment         = var.environment
  cors_allowed_origin = var.aq_bucket_cors_allowed_origin
}

module "canaries" {
  count            = var.deploy_canaries ? 1 : 0
  source           = "./modules/canaries"
  email_recipients = var.email_recipients
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
