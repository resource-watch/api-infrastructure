environment                              = "production"
elasticsearch_disk_size_gb               = 512
elasticsearch_use_dedicated_master_nodes = true
elasticsearch_data_nodes_count           = 4
backups_bucket                           = "wri-api-production-backups"
dns_prefix                               = "prod"
tf_core_state_bucket                     = "wri-api-terraform"
deploy_metrics_server                    = true
elasticsearch_data_nodes_type            = "m5.large.elasticsearch"
x_rw_domain                              = "api.resourcewatch.org"
namespaces                               = ["core", "aqueduct", "rw", "gfw", "fw", "prep", "climate-watch", "gateway"]