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

variable "elasticsearch_disk_size_gb" {
  type        = number
  description = "Disk size for each Elasticsearch data node (numeric value in GBs)."
}

variable "backups_bucket" {
  type        = string
  description = "S3 bucket to which backups will be performed"
}