variable "project" {
  type        = string
  description = "A project namespace for the infrastructure."
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC."
}

variable "subnet_id" {
  type        = string
  description = "The public subnet ids to which the Jenkins EC2 instance will be connected."
}

variable "jenkins_instance_type" {
  default     = "m5a.large"
  type        = string
  description = "An instance type for the bastion."
}

variable "tags" {
  default     = {}
  type        = map(string)
  description = "A mapping of keys and values to apply as tags to all resources that support them."
}

variable "security_group_ids" {
  type        = list(string)
  description = "A list of security groups to use for the Jenkins EC2 instance"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
  description = "A list of availability zones for subnet placement."
}

variable "user_data" {
  description = "User data for bootstrapping Bastion host"
}

variable "jenkins_ami" {
  type        = string
  description = "An AMI ID for the Jenkins EC2 instance."
}

variable "iam_instance_profile_role" {
  description = "Role for the Jenkins EC2 instance profile."
}