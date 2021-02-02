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

variable "v1_resource_root" {
  type = object({
    id = string
  })
  description = "Instance of v1 aws_api_gateway_resource"
}

variable "v2_resource_root" {
  type = object({
    id = string
  })
  description = "Instance of v2 aws_api_gateway_resource"
}

variable "v3_resource_root" {
  type = object({
    id = string
  })
  description = "Instance of v3 aws_api_gateway_resource"
}