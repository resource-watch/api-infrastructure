variable "name_suffix" {
  type        = string
  description = "API Name suffix"
}

variable "dns_prefix" {
  type        = string
  description = "DNS prefix"
}

variable "endpoint_list" {
  type        = list(string)
  description = "list of endpoints. When changed, triggers a redeployment"
}