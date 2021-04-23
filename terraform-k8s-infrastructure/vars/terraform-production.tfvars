environment                              = "production"
elasticsearch_disk_size_gb               = 700
elasticsearch_use_dedicated_master_nodes = true
elasticsearch_data_nodes_count           = 3
backups_bucket                           = "wri-api-production-backups"
dns_prefix                               = "prod"
tf_core_state_bucket                     = "wri-api-terraform"
deploy_metrics_server                    = true
