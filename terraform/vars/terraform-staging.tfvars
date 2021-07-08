environment                     = "staging"
ingress_allow_cidr_block        = "0.0.0.0/0"
dns_prefix                      = "aws-staging"
backups_bucket                  = "wri-api-staging-backups"
log_retention_period            = 7
backup_retention_period         = 1
rds_engine_version              = "11.9"
rds_instance_class              = "db.t3.medium"
rds_instance_count              = 1
db_instance_class               = "db.r5.large"
db_instance_count               = 2
db_logs_exports                 = ["audit", "profiler"]
eks_version                     = "1.20"
eks_node_release_version        = "1.20.4-20210628"
gateway_node_group_desired_size = 0
hibernate                       = false