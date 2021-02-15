variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "resource_root_id" {
  type        = string
  description = "Id of the root aws_api_gateway_resource"
}