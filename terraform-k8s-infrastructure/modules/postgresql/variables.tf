variable "project" {
  type = string
}

variable "tags" {
  type        = map(string)
  description = "Tags to add to resources"
}

variable "rds_host" {
  type = string
}

variable "rds_port" {
  type = number
}
variable "rds_dbname" {
  type = string
}

variable "rds_username" {
  type = string
}

variable "rds_password" {
  type        = string
  description = "Superuser Password for Aurora Database"
}

variable "postgresql_databases" {
  type        = list(string)
  description = "List of PG databases to create."
}