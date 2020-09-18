variable "subnet_ids" {
  type        = list(string)
  description = "A list of public subnet ids to which the EKS cluster will be connected."
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

variable "backups_bucket" {
  type        = string
  description = "S3 bucket to which backups will be performed"
}

variable "security_group_ids" {
  type        = list(string)
  description = "Security group ids to add to cluster"
}