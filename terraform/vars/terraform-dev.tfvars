environment                 = "dev"
ingress_allow_cidr_block    = "0.0.0.0/0"
dns_prefix                  = "aws-dev"
backups_bucket              = "wri-api-dev-backups"
rds_backup_retention_period = 1
log_retention_period        = 7
rds_instance_class          = "db.t3.medium"
rds_instance_count          = 1