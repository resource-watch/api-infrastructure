environment                              = "dev"
elasticsearch_disk_size_gb               = 350
elasticsearch_use_dedicated_master_nodes = false
elasticsearch_data_nodes_count           = 3
backups_bucket                           = "wri-api-dev-backups"
dns_prefix                               = "dev"
tf_core_state_bucket                     = "wri-api-terraform-dev"
deploy_metrics_server                    = false
elasticsearch_data_nodes_type            = "m5.large.elasticsearch"
x_rw_domain                              = "dev-api.resourcewatch.org"
namespaces                               = ["core", "aqueduct", "rw", "gfw", "fw", "prep", "climate-watch"]
fw_backend_url                           = "https://dev-fw-api.globalforestwatch.org"