variable "cluster_endpoint" {
  type        = string
  description = "The k8s cluster endpoint. Must be accessible from localhost"
}

variable "cluster_ca" {
  type        = string
  description = "The k8s CA string"
}

variable "cluster_name" {
  type        = string
  description = "The k8s cluster name"
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
  description = "The id of the VPC"
}

variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "The name of the AWS region where the cluster lives"
}

variable "elasticsearch_disk_size_gb" {
  type        = number
  description = "Disk size for each Elasticsearch data node (numeric value in GBs)"
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
  description = "Name of the S3 bucket containing ES backup snapshots"
}