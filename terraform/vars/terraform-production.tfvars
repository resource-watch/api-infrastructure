environment              = "production"
ingress_allow_cidr_block = "0.0.0.0/0"
dns_prefix               = "aws-prod"
backups_bucket           = "wri-api-production-backups"
log_retention_period     = 30
backup_retention_period  = 7
rds_instance_class       = "db.r5.large"
rds_instance_count       = 1
db_instance_class        = "db.r5.large"
db_instance_count        = 3
db_logs_exports          = ["audit", "profiler"]
