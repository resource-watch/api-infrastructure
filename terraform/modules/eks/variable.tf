variable "subnet_ids" {
  type        = list(string)
  description = "A list of public subnet ids to which the EKS cluster will be connected."
}

variable "aws_region" {
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC."
}

variable "eks_version" {
  type        = string
  description = "Version of EKS (kubernetes) to deploy"
}

variable "ebs_csi_addon_version" {
  type        = string
  description = "Version of AWS EBS CRI driver to use"
}

variable "backups_bucket" {
  type        = string
  description = "S3 bucket to which backups will be performed"
}
