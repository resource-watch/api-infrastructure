variable "dns_prefix" {
  type        = string
  description = "DNS prefix"
}

variable "vpc" {
  type = object({
    id         = string
    cidr_block = string
  })
  description = "The id of the VPC"
}

variable "environment" {
  type        = string
  description = "Environment name"
}
