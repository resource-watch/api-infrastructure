environment              = "staging"
ingress_allow_cidr_block = "0.0.0.0/0"
dns_prefix               = "aws-staging"
backups_bucket           = "wri-api-staging-backups"
log_retention_period     = 7
backup_retention_period  = 1
rds_instance_class       = "db.t3.medium"
rds_instance_count       = 1