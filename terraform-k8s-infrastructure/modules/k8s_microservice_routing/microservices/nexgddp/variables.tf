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

variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
  description = "The id of the VPC"
  default     = null
}

variable "vpc_link" {
  type = object({
    id          = string
    target_arns = list(string)
  })
  description = "VPC Link to the LB"
  default     = { id : null, target_arns : [] }
}

variable "require_api_key" {
  type    = bool
  default = false
}

variable "connection_type" {
  type        = string
  description = "API Gateway integration type"
}

variable "eks_asg_names" {
  type        = list(any)
  description = "List of the EKS ASG names"
  default     = []
}

variable "target_url" {
  type        = string
  description = "Target URL"
  default     = null
}

variable "v1_resource" {
  type = object({
    id = string
  })
}

variable "v1_query_resource" {
  type = object({
    id = string
  })
}

variable "v1_download_resource" {
  type = object({
    id = string
  })
}

variable "v1_fields_resource" {
  type = object({
    id = string
  })
}

variable "v1_rest_datasets_resource" {
  type = object({
    id = string
  })
}

variable "v1_layer_id_tile_resource" {
  type = object({
    id = string
  })
}

variable "v1_layer_resource" {
  type = object({
    id = string
  })
}
