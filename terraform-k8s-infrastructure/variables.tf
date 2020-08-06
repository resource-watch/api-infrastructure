variable "project" {
  default     = "WRI API"
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "environment" {
  type        = string
  description = "An environment namespace for the infrastructure."
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for public URLs created in this project."
}

variable "application" {
  default     = "wri-api-aws-core-infrastructure"
  type        = string
  description = "Name of the current application"
}

variable "dynamo_db_lock_table_name" {
  default     = "aws-locks"
  type        = string
  description = "Name of the lock table in Dynamo DB"
}

variable "elasticsearch_disk_size" {
  type        = string
  description = "Disk size for each Elasticsearch data node."
}