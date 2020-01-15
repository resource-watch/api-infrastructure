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
  version = "~> 2.36.0"
}

# Call the seed_module to build our ADO seed info
module "bootstrap" {
  source               = "./modules/bootstrap"
  s3_bucket            = local.tf_state_bucket
  dynamo_db_table_name = var.dynamo_db_lock_table_name
  tags                 = local.tags
}


module "vpc" {
  source             = "./modules/vpc"
  region             = var.aws_region
  key_name           = var.ssh_key_name
  bastion_ami        = data.aws_ami.amazon_linux_ami.id
  project            = local.project
  tags               = local.tags
  security_group_ids = [aws_security_group.default.id]
}
