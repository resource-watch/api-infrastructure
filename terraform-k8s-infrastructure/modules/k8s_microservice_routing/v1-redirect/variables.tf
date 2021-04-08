variable "api_gateway" {
  type = object({
    id               = string
    root_resource_id = string
  })
  description = "Instance of aws_api_gateway_rest_api"
}

variable "target_domain" {
  type        = string
  description = "Target URL to which the requests are redirected"
}