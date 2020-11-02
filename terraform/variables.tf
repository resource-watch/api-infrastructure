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

variable "ingress_allow_cidr_block" {
  type        = string
  description = "The CIDR block of IPs allowed to connect to the bastion host."
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix for public URLs created in this project."
}

variable "backups_bucket" {
  type        = string
  description = "S3 bucket to which backups will be performed"
}

variable "gateway_node_group_instance_types" {
  type    = string
  default = "m5a.large"
}
variable "gateway_node_group_min_size" {
  type    = number
  default = 2
}
variable "gateway_node_group_max_size" {
  type    = number
  default = 6
}
variable "gateway_node_group_desired_size" {
  type    = number
  default = 2
}

variable "elasticsearch_node_group_instance_types" {
  type    = string
  default = "m5a.xlarge"
}
variable "elasticsearch_node_group_min_size" {
  type    = number
  default = 3
}
variable "elasticsearch_node_group_max_size" {
  type    = number
  default = 3
}
variable "elasticsearch_node_group_desired_size" {
  type    = number
  default = 3
}

variable "mongodb_apps_node_group_instance_types" {
  type    = string
  default = "r5a.large"
}
variable "mongodb_apps_node_group_min_size" {
  type    = number
  default = 3
}
variable "mongodb_apps_node_group_max_size" {
  type    = number
  default = 3
}
variable "mongodb_apps_node_group_desired_size" {
  type    = number
  default = 3
}

variable "apps_node_group_instance_types" {
  type    = string
  default = "r5a.large"
}
variable "apps_node_group_min_size" {
  type    = number
  default = 1
}
variable "apps_node_group_max_size" {
  type    = number
  default = 16
}
variable "apps_node_group_desired_size" {
  type    = number
  default = 3
}
variable "apps_node_group_min_size_upscaled" {
  type    = number
  default = 1
}

variable "webapps_node_group_instance_types" {
  type    = string
  default = "r5a.large"
}
variable "webapps_node_group_min_size" {
  type    = number
  default = 1
}
variable "webapps_node_group_max_size" {
  type    = number
  default = 4
}
variable "webapps_node_group_desired_size" {
  type    = number
  default = 2
}

variable "gfw_node_group_instance_types" {
  type    = string
  default = "r5a.large"
}
variable "gfw_node_group_min_size" {
  type    = number
  default = 1
}
variable "gfw_node_group_max_size" {
  type    = number
  default = 4
}
variable "gfw_node_group_desired_size" {
  type    = number
  default = 4
}
variable "gfw_node_group_min_size_upscaled" {
  type    = number
  default = 1
}

variable "gfw_pro_node_group_instance_types" {
  type    = string
  default = "m5a.large"
}
variable "gfw_pro_node_group_min_size" {
  type    = number
  default = 1
}
variable "gfw_pro_node_group_max_size" {
  type    = number
  default = 1
}
variable "gfw_pro_node_group_desired_size" {
  type    = number
  default = 1
}

variable "core_node_group_instance_types" {
  type    = string
  default = "r5a.large"
}
variable "core_node_group_min_size" {
  type    = number
  default = 2
}
variable "core_node_group_max_size" {
  type    = number
  default = 4
}
variable "core_node_group_desired_size" {
  type    = number
  default = 2
}

variable "backup_retention_period" {
  type        = number
  description = "Number of days to keep Aurora PostgreSQL backups"
}

variable "log_retention_period" {
  type        = number
  description = "Time in days to keep log files in cloud watch"
}

variable "rds_instance_class" {
  type        = string
  description = "Instance type of Aurora PostgreSQL server"
}

variable "rds_instance_count" {
  type        = number
  description = "Number of Aurora PostgreSQL instances before autoscaling"
}
