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
}

variable "vpc_link" {
  type = object({
    id          = string
    target_arns = list(string)
  })
  description = "VPC Link to the LB"
}

variable "eks_asg_names" {
  type        = list(any)
  description = "List of the EKS ASG names"
}

variable "v1_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_id_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_id_widget_id_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_id_widget_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_id_layer_id_resource" {
  type = object({
    id = string
  })
}

variable "v1_dataset_id_layer_resource" {
  type = object({
    id = string
  })
}