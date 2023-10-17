variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "api_resource" {
  type = object({
    id        = string
    path_part = string
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

variable "endpoint_request_parameters" {
  type        = list(string)
  description = "Additional request_parameters values to add to the API Gateway endpoint_integration and endpoint_method"
  default     = []
}

variable "x_rw_domain" {
  type        = string
  description = "Value to be passed as the x-rw-domain header"
}

variable "connection_type" {
  type        = string
  description = "API Gateway integration type"
}

variable "require_api_key" {
  type    = bool
  default = false
}
