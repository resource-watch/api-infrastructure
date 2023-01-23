environment                     = "staging"
ingress_allow_cidr_block        = "0.0.0.0/0"
dns_prefix                      = "aws-staging"
backups_bucket                  = "wri-api-staging-backups"
log_retention_period            = 7
backup_retention_period         = 1
rds_engine_version              = "11.13"
rds_instance_class              = "db.t3.medium"
rds_instance_count              = 1
db_instance_class               = "db.r5.large"
db_instance_count               = 2
db_logs_exports                 = ["audit", "profiler"]
eks_version                     = "1.24"
eks_node_release_version        = "1.24.7-20230105"
ebs_csi_addon_version           = "v1.15.0-eksbuild.1"
gateway_node_group_desired_size = 0
hibernate                       = false

apps_node_group_capacity_type  = "SPOT"
apps_node_group_instance_types = ["c5a.large", "c5a.xlarge", "c5.large", "c5.xlarge"]

gfw_node_group_capacity_type  = "SPOT"
gfw_node_group_instance_types = ["c5a.large", "c5a.xlarge", "c5.large", "c5.xlarge"]

webapps_node_group_capacity_type  = "SPOT"
webapps_node_group_instance_types = ["c5a.large", "c5a.xlarge", "c5.large", "c5.xlarge"]

core_node_group_capacity_type  = "SPOT"
core_node_group_instance_types = ["c5a.large", "c5a.xlarge", "c5.large", "c5.xlarge"]

mongodb_apps_node_group_capacity_type  = "SPOT"
mongodb_apps_node_group_instance_types = ["r5a.large", "r5.large"]

aq_bucket_cors_allowed_origin = "*"
deploy_sparkpost_templates    = false
