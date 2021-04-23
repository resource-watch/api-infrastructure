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

variable "elasticsearch_disk_size_gb" {
  type        = number
  description = "Disk size for each Elasticsearch data node (numeric value in GBs)."
}

variable "elasticsearch_use_dedicated_master_nodes" {
  type        = bool
  default     = false
  description = "If the cluster should use dedicated master nodes"
}

variable "elasticsearch_data_nodes_count" {
  type        = number
  default     = 3
  description = "Number of data nodes to use on the ES cluster"
}

variable "backups_bucket" {
  type        = string
  description = "S3 bucket to which backups will be performed"
}

variable "tf_core_state_bucket" {
  type        = string
  description = "S3 bucket that holds the core TF state"
}