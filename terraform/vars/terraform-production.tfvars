environment                     = "production"
ingress_allow_cidr_block        = "0.0.0.0/0"
dns_prefix                      = "aws-prod"
backups_bucket                  = "wri-api-production-backups"
log_retention_period            = 30
backup_retention_period         = 7
rds_engine_version              = "11.9"
rds_instance_class              = "db.r5.large"
rds_instance_count              = 1
db_instance_class               = "db.r5.large"
db_instance_count               = 3
db_logs_exports                 = ["audit", "profiler"]
eks_version                     = "1.20"
eks_node_release_version        = "1.20.4-20210628"
deploy_canaries                 = true
gateway_node_group_desired_size = 2
hibernate                       = false
aq_bucket_cors_allowed_origin   = "https://wri.org/"