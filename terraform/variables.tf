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
  type    = list(string)
  default = ["m5a.large"]
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

variable "mongodb_apps_node_group_instance_types" {
  type    = list(string)
  default = ["r5a.large"]
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

variable "mongodb_apps_node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "apps_node_group_instance_types" {
  type    = list(string)
  default = ["c5a.xlarge"]
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

variable "apps_node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "webapps_node_group_instance_types" {
  type    = list(string)
  default = ["c5a.xlarge"]
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

variable "webapps_node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "gfw_node_group_instance_types" {
  type    = list(string)
  default = ["c5a.xlarge"]
}
variable "gfw_node_group_min_size" {
  type    = number
  default = 1
}
variable "gfw_node_group_max_size" {
  type    = number
  default = 5
}
variable "gfw_node_group_desired_size" {
  type    = number
  default = 4
}
variable "gfw_node_group_min_size_upscaled" {
  type    = number
  default = 1
}

variable "gfw_node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "core_node_group_instance_types" {
  type    = list(string)
  default = ["c5.xlarge"] # core node group has to run in a specific AZ due to its persistent storage. The AZ we initially chose does not have c5a instances.
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

variable "core_node_group_capacity_type" {
  type    = string
  default = "ON_DEMAND"
}

variable "backup_retention_period" {
  type        = number
  description = "Time in days to keep db backups"
}

variable "log_retention_period" {
  type        = number
  description = "Time in days to keep log files in cloud watch"
}

variable "rds_engine_version" {
  type        = string
  description = "Engine version of Aurora PostgreSQL server"
}

variable "rds_instance_class" {
  type        = string
  description = "Instance type of Aurora PostgreSQL server"
}

variable "rds_instance_count" {
  type        = number
  description = "Number of Aurora PostgreSQL instances before autoscaling"
}

variable "db_instance_class" {
  type        = string
  description = "Instance type of DocumentDB server"
}

variable "db_instance_count" {
  type        = number
  description = "Number of DocumentDB instances"
}

variable "db_logs_exports" {
  type        = list(string)
  description = "List of log types to export to cloudwatch. The following log types are supported: `audit`, `error`, `general`, `slowquery`"
}

variable "deploy_canaries" {
  type        = bool
  default     = false
  description = "If canaries should be deployed"
}

variable "eks_version" {
  type        = string
  description = "Version of EKS (kubernetes) to deploy"
}

variable "eks_node_release_version" {
  type        = string
  description = "Version of EKS (kubernetes) node AMI to deploy"
}

variable "hibernate" {
  description = "If set to true, the EKS cluster will be scaled down and its services unavailable"
  type        = bool
  default     = false
}