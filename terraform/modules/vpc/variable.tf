variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "region" {
  type        = string
  description = "A valid AWS region to house VPC resources."
}

variable "cidr_block" {
  default     = "10.0.0.0/16" // 10.0.0.0 - 10.0.255.255
  type        = string
  description = "The CIDR range for the entire VPC."
}

variable "public_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.0.0.0/20", # 10.0.0.0 - 10.0.15.255
    "10.0.16.0/20",         # 10.0.16.0 - 10.0.31.255
    "10.0.32.0/20",         # 10.0.32.0 - 10.0.47.255
    "10.0.48.0/20",         # 10.0.48.0 - 10.0.63.255
    "10.0.64.0/20",         # 10.0.64.0 - 10.0.79.255
  "10.0.80.0/20"]           # 10.0.80.0 - 10.0.95.255
  description = "A list of CIDR ranges for public subnets."
}

variable "private_subnet_cidr_blocks" {
  type = list(string)
  default = ["10.0.112.0/20", # 10.0.112.0 - 10.0.127.255
    "10.0.128.0/20",          # 10.0.128.0 - 10.0.143.255
    "10.0.144.0/20",          # 10.0.144.0 - 10.0.159.255
    "10.0.160.0/20",          # 10.0.160.0 - 10.0.175.255
    "10.0.176.0/20",          # 10.0.176.0 - 10.0.191.255
  "10.0.192.0/20"]            # 10.0.192.0 - 10.0.207.255
  description = "A list of CIDR ranges for private subnets."
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  description = "A list of availability zones for subnet placement."
}

variable "bastion_ami" {
  type        = string
  description = "An AMI ID for the bastion."
}

variable "bastion_instance_type" {
  default     = "t3.nano"
  type        = string
  description = "An instance type for the bastion."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}

variable "private_subnet_tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all private subnets managed by this module."
}

variable "public_subnet_tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all public subnets managed by this module."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security groups to use for the bastion"
}

variable "user_data" {
  description = "User data for bootstrapping Bastion host"
}