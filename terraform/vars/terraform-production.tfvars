environment                 = "production"
ingress_allow_cidr_block    = "0.0.0.0/0"
dns_prefix                  = "aws-prod"
backups_bucket              = "wri-api-production-backups"
rds_backup_retention_period = 7
log_retention_period        = 30
rds_instance_class          = "db.r5.large"
rds_instance_count          = 1