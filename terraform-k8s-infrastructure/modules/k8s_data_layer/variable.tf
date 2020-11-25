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

variable "elasticsearch_disk_size" {
  type        = string
  description = "Disk size for each Elasticsearch data node"
}

variable "elasticsearch_disk_size_gb" {
  type        = number
  description = "Disk size for each Elasticsearch data node (numeric value in GBs)"
}

variable "backups_bucket" {
  type        = string
  description = "Name of the S3 bucket containing ES backup snapshots"
}