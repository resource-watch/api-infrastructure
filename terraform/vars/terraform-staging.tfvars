environment                 = "staging"
ingress_allow_cidr_block    = "0.0.0.0/0"
dns_prefix                  = "aws-staging"
backups_bucket              = "wri-api-staging-backups"
rds_backup_retention_period = 1
log_retention_period        = 7
rds_instance_class          = "db.t3.medium"
rds_instance_count          = 1