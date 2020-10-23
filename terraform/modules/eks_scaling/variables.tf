variable "lambda_eks_scaling_python_runtime" {
  default = "python3.7"
}

variable "eks_cluster_name" {
  type = string
}

# Keep Lambda execution logs for 7 days
variable "log_retention" {
  type    = number
  default = 7
}

# Starting at 10pm, upscale the cluster and
# check every 15 minutes just to be safe
variable "cw_upscale_crontab" {
  type = string
  # TEMP: Do every 30 minutes just for testing
  # Actually should be "cron(*/15 22,23 * * *)"
  default = "cron(15-59/30 * * * *)"

}

# At midnight, downscale the cluster and
# check again at 12:15am just to safe
variable "cw_downscale_crontab" {
  type = string
  # TEMP: Do every 30 minutes just for testing
  # Actually should be "cron(0,15 0 * * *)"
  default = "cron(*/30 * * * *)"
}

# Scaling config variables for apps-node-group
variable "apps_node_group_min_size" {
  type = number
}
variable "apps_node_group_max_size" {
  type = number
}
variable "apps_node_group_desired_size" {
  type = number
}
variable "apps_node_group_min_size_upscaled" {
  type    = number
  default = -1
}
variable "apps_node_group_max_size_upscaled" {
  type    = number
  default = -1
}
variable "apps_node_group_desired_size_upscaled" {
  type    = number
  default = -1
}

# Scaling config variables for gfw-node-group
variable "gfw_node_group_min_size" {
  type = number
}
variable "gfw_node_group_max_size" {
  type = number
}
variable "gfw_node_group_desired_size" {
  type = number
}
variable "gfw_node_group_min_size_upscaled" {
  type    = number
  default = -1
}
variable "gfw_node_group_max_size_upscaled" {
  type    = number
  default = -1
}
variable "gfw_node_group_desired_size_upscaled" {
  type    = number
  default = -1
}
