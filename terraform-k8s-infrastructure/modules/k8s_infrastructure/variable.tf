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

variable "vpc_id" {
  type        = string
  description = "The id of the VPC"
}

variable "aws_region" {
  type        = string
  description = "The name of the AWS region where the cluster lives"
}