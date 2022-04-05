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

variable "method" {
  type        = string
  description = "Endpoint method"
}

variable "backend_url" {
  type        = string
  description = "The URL of the backend server to which the request is proxied"
}