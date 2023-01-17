variable "x_rw_domain" {
  type        = string
  default     = "localhost"
  description = "Value to be passed as the x-rw-domain header"
}

variable "microservice_host" {
  type        = string
  description = "Host in which the microservices will be available. Must be accessible from Localstack's running host (so if you are using docker, \"locahost\" won't work. Your local IP address might be a good guess"
}
