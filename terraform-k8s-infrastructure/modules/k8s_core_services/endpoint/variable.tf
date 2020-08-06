variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "api_resource" {
  type = object({
    id = string
  })
  description = "Instance of aws_api_gateway_resource"
}

variable "vpc_link" {
  type = object({
    id = string
  })
  description = "Instance of aws_api_gateway_vpc_link"
}

variable "uri" {
  type        = string
  description = "Target uri"
}

variable "method" {
  type        = string
  description = "Endpoint method"
}
