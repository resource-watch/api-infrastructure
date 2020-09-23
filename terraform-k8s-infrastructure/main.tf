terraform {
  backend "s3" {
    region         = "us-east-1"
    key            = "k8s-infrastructure.tfstate"
    dynamodb_table = "aws-locks"
    encrypt        = true
  }
}

# import core state
data "terraform_remote_state" "core" {
  backend = "s3"
  config = {
    bucket = local.tf_state_bucket
    region = "us-east-1"
    key    = "core.tfstate"
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

module "postgresql" {
  source               = "./modules/postgresql"
  postgresql_databases = ["resource-watch-manager"]
  project              = local.project
  tags                 = local.tags
  rds_dbname           = data.terraform_remote_state.core.outputs.aurora_dbname
  rds_host             = data.terraform_remote_state.core.outputs.aurora_host
  rds_port             = data.terraform_remote_state.core.outputs.aurora_port
  rds_username         = data.terraform_remote_state.core.outputs.aurora_user_name
  rds_password         = var.rds_password
}

module "resource_watch" {
  source    = "./modules/k8s_namespaces"
  namespace = "rw"
  app_secrets = {
    RW_GOGGLE_API_TOKEN_SHORTENER = ""
    RW_MAPBOX_API_TOKEN           = ""
    RW_SECRET                     = ""
    RW_SENDGRID_API_KEY           = ""
    RW_SENDGRID_PASSWORD          = ""
    RW_SENDGRID_USERNAME          = ""
    RW_PREPROD_AUTH_USER          = ""
    RW_PREPROD_AUTH_PASSWORD      = ""
    RW_STAGING_AUTH_USER          = ""
    RW_STAGING_AUTH_PASSWORD      = ""
  }
  db_secrets = {
    REDIS_URI                         = ""
    RESOURCE_WATCH_MANAGER_POSTGRESDB = module.postgresql.passwords["resource-watch-manager"]

  }
  ms_secrets = {
    CT_TOKEN             = ""
    CT_URL               = ""
    S3_ACCESS_KEY_ID     = ""
    S3_SECRET_ACCESS_KEY = ""
  }
  container_registry_server   = ""
  container_registry_username = ""
  container_registry_password = ""
}

module "gateway" {
  source    = "./modules/k8s_namespaces"
  namespace = "gateway"
}

module "core" {
  source    = "./modules/k8s_namespaces"
  namespace = "core"
}

module "aqueduct" {
  source    = "./modules/k8s_namespaces"
  namespace = "aqueduct"
}

module "gfw" {
  source    = "./modules/k8s_namespaces"
  namespace = "gfw"
}

module "fw" {
  source    = "./modules/k8s_namespaces"
  namespace = "fw"
}

module "prep" {
  source    = "./modules/k8s_namespaces"
  namespace = "fw"
}

module "climate-watch" {
  source    = "./modules/k8s_namespaces"
  namespace = "fw"
}
