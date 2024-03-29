variable "cluster_endpoint" {
  type        = string
  description = "The k8s cluster endpoint. Must be accessible from localhost"
  default     = null
}

variable "cluster_ca" {
  type        = string
  description = "The k8s CA string"
  default     = null
}

variable "cluster_name" {
  type        = string
  description = "The k8s cluster name"
  default     = null
}

variable "x_rw_domain" {
  type        = string
  description = "Value to be passed as the x-rw-domain header"
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
  description = "The id of the VPC"
  default     = null
}

variable "environment" {
  type        = string
  description = "Environment name"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix"
}

variable "aws_region" {
  default     = "us-east-1"
  type        = string
  description = "A valid AWS region to configure the underlying AWS SDK."
}

variable "project" {
  default     = "WRI API"
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "tf_core_state_bucket" {
  type        = string
  description = "S3 bucket that holds the core TF state"
}

variable "fw_backend_url" {
  type        = string
  description = "The URL of the backend server to which the request is proxied"
}

variable "require_api_key" {
  type    = bool
  default = false
}
