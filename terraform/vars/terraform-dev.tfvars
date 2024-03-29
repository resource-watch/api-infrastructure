environment              = "dev"
ingress_allow_cidr_block = "0.0.0.0/0"
dns_prefix               = "aws-dev"
backups_bucket           = "wri-api-dev-backups"
log_retention_period     = 7
backup_retention_period  = 1
rds_engine_version       = "11.17"
rds_instance_class       = "db.t3.medium"
rds_instance_count       = 1
db_instance_class        = "db.t3.medium"
db_instance_count        = 1
db_logs_exports          = ["audit", "profiler"]
eks_version              = "1.29"
eks_node_release_version = "1.29.0-20240202"
ebs_csi_addon_version    = "v1.27.0-eksbuild.1"
# apps_node_group_min_size          = 1
# apps_node_group_max_size          = 16
# apps_node_group_desired_size      = 3
# apps_node_group_min_size_upscaled = 2
# gfw_node_group_min_size           = 1
# gfw_node_group_max_size           = 4
# gfw_node_group_desired_size       = 4
# gfw_node_group_min_size_upscaled  = 2
gateway_node_group_desired_size = 0
hibernate                       = true
aq_bucket_cors_allowed_origin   = "*"
deploy_sparkpost_templates      = false
