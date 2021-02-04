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

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix"
}