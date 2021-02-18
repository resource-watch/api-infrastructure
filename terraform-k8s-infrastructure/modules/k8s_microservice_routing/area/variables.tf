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

variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "resource_root_v1_id" {
  type        = string
  description = "Id of the root aws_api_gateway_resource"
}

variable "resource_root_v2_id" {
  type        = string
  description = "Id of the root aws_api_gateway_resource"
}