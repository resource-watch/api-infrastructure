terraform {
}

resource "aws_api_gateway_account" "api_gateway_monitoring_account" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_monitoring.arn
}

resource "aws_iam_role" "api_gateway_monitoring" {
  name = "api_gateway_cloudwatch_global"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_api_gateway_method_settings" "rw_api_gateway_general_settings" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = false
    data_trace_enabled = false
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_rest_api" "rw_api_gateway" {
  name        = "rw-api-localstack"
  description = "API Gateway for the RW API localstack cluster"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(join(",", list(
      jsonencode(module.analysis-gee.endpoints),
      jsonencode(module.aqueduct-analysis.endpoints),
      jsonencode(module.arcgis-proxy.endpoints),
      jsonencode(module.arcgis.endpoints),
      jsonencode(module.area.endpoints),
      jsonencode(module.auth.endpoints),
      jsonencode(module.bigquery.endpoints),
      jsonencode(module.biomass.endpoints),
      jsonencode(module.carto.endpoints),
      jsonencode(module.converter.endpoints),
      jsonencode(module.dataset.endpoints),
      jsonencode(module.doc-orchestrator.endpoints),
      jsonencode(module.document-adapter.endpoints),
      jsonencode(module.fires-summary-stats.endpoints),
      jsonencode(module.forest-change.endpoints),
      jsonencode(module.gee-tiles.endpoints),
      jsonencode(module.gee.endpoints),
      jsonencode(module.geostore.endpoints),
      jsonencode(module.gfw-adapter.endpoints),
      jsonencode(module.gfw-contact.endpoints),
      jsonencode(module.gfw-guira.endpoints),
      jsonencode(module.gfw-forma.endpoints),
      jsonencode(module.gfw-ogr.endpoints),
      jsonencode(module.gfw-ogr-gfw-pro.endpoints),
      jsonencode(module.gfw-prodes.endpoints),
      jsonencode(module.gfw-umd.endpoints),
      jsonencode(module.gfw-user.endpoints),
      jsonencode(module.glad-analysis-tiled.endpoints),
      jsonencode(module.graph-client.endpoints),
      jsonencode(module.gs-pro-config.endpoints),
      jsonencode(module.high-res.endpoints),
      jsonencode(module.imazon.endpoints),
      jsonencode(module.layer.endpoints),
      jsonencode(module.metadata.endpoints),
      jsonencode(module.nexgddp.endpoints),
      jsonencode(module.proxy.endpoints),
      jsonencode(module.query.endpoints),
      jsonencode(module.quicc.endpoints),
      jsonencode(module.rw-lp),
      jsonencode(module.resource-watch-manager),
      jsonencode(module.salesforce-connector),
      jsonencode(module.story),
      jsonencode(module.subscriptions),
      jsonencode(module.task-executor.endpoints),
      jsonencode(module.true-color-tiles.endpoints),
      jsonencode(module.viirs-fires.endpoints),
      jsonencode(module.vocabulary.endpoints),
      jsonencode(module.webshot.endpoints),
      jsonencode(module.widget.endpoints),
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

#
# Endpoint creation
#

// Base API Gateway resources
module "v1_resource" {
  source      = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v1"
}

module "v2_resource" {
  source      = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v2"
}

module "v3_resource" {
  source      = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/resource"
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  parent_id   = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
  path_part   = "v3"
}

// /v1 200 response, needed by FW
resource "aws_api_gateway_method" "get_v1_endpoint_method" {
  rest_api_id   = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id   = module.v1_resource.aws_api_gateway_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "get_v1_endpoint_integration" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" : "{\"statusCode\": 200}"
  }
  depends_on = [aws_api_gateway_method.get_v1_endpoint_method]
}

resource "aws_api_gateway_method_response" "get_v1_endpoint_method_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = 200
}

resource "aws_api_gateway_integration_response" "get_v1_endpoint_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.rw_api_gateway.id
  resource_id = module.v1_resource.aws_api_gateway_resource.id
  http_method = aws_api_gateway_method.get_v1_endpoint_method.http_method
  status_code = aws_api_gateway_method_response.get_v1_endpoint_method_response.status_code

  # Transforms the backend JSON response to XML
  response_templates = {
    "application/json" = <<EOF
#set($inputRoot = $input.path('$'))
{ }
EOF
  }
}

module "analysis-gee" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/analysis-gee"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  v2_resource     = module.v2_resource.aws_api_gateway_resource

  depends_on = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "aqueduct-analysis" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/aqueduct-analysis"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "arcgis" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/arcgis"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  depends_on                = [
    module.dataset,
  ]
}

module "arcgis-proxy" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/arcgis-proxy"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "area" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/area"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource

  depends_on = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "auth" {
  source      = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/authorization"
  api_gateway = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain = var.x_rw_domain

  v1_resource      = module.v1_resource.aws_api_gateway_resource
  connection_type  = "INTERNET"
  target_url       = var.microservice_host
  root_resource_id = aws_api_gateway_rest_api.rw_api_gateway.root_resource_id
}

module "bigquery" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/bigquery"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  depends_on                = [
    module.dataset,
    module.query,
  ]
}

module "biomass" {
  source                   = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/biomass"
  api_gateway              = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain              = var.x_rw_domain
  connection_type          = "INTERNET"
  target_url               = var.microservice_host
  v1_resource              = module.v1_resource.aws_api_gateway_resource
  v1_biomass_loss_resource = module.analysis-gee.v1_biomass_loss_resource
  depends_on               = [
    module.analysis-gee
  ]
}

module "carto" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/carto"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  depends_on                = [
    module.dataset,
    module.query,
  ]
}

module "converter" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/converter"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "dataset" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/dataset"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host

}

module "doc-orchestrator" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/doc-orchestrator"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "document-adapter" {
  source                 = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/document-adapter"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain            = var.x_rw_domain
  connection_type        = "INTERNET"
  target_url             = var.microservice_host
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource
  v1_query_resource      = module.query.v1_query_resource
  v1_download_resource   = module.query.v1_download_resource
  v1_fields_resource     = module.query.v1_fields_resource

  depends_on = [
    module.dataset,
    module.query,
  ]
}

module "fires-summary-stats" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/fires-summary-stats"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "forest-change" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/forest-change"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "gee" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gee"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource

  depends_on = [
    module.dataset
  ]
}

module "gee-tiles" {
  source               = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gee-tiles"
  api_gateway          = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain          = var.x_rw_domain
  connection_type      = "INTERNET"
  target_url           = var.microservice_host
  v1_resource          = module.v1_resource.aws_api_gateway_resource
  v1_layer_resource    = module.layer.v1_layer_resource
  v1_layer_id_resource = module.layer.v1_layer_id_resource

  depends_on = [
    module.layer
  ]
}

module "geostore" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/geostore"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource
}

module "gfw-adapter" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-adapter"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  depends_on                = [
    module.dataset,
    module.query,
  ]
}

module "gfw-contact" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-contact"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "gfw-forma" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-forma"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "gfw-guira" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-guira"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource
}

module "gfw-ogr" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-ogr"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource
}

module "gfw-ogr-gfw-pro" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-ogr-gfw-pro"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "gfw-prodes" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-prodes"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource
}

module "gfw-umd" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-umd"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v2_resource               = module.v2_resource.aws_api_gateway_resource
  v3_resource               = module.v3_resource.aws_api_gateway_resource
  v1_umd_loss_gain_resource = module.analysis-gee.v1_umd_loss_gain_resource
}

module "gfw-user" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gfw-user"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  v2_resource     = module.v2_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "glad-analysis-tiled" {
  source                  = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/glad-analysis-tiled"
  api_gateway             = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain             = var.x_rw_domain
  connection_type         = "INTERNET"
  target_url              = var.microservice_host
  v1_resource             = module.v1_resource.aws_api_gateway_resource
  v1_glad_alerts_resource = module.fires-summary-stats.v1_glad_alerts_resource
  depends_on              = [
    module.fires-summary-stats
  ]
}

module "graph-client" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/graph-client"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "gs-pro-config" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/gs-pro-config"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "high-res" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/high-res"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "imazon" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/imazon"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v2_resource     = module.v2_resource.aws_api_gateway_resource
  depends_on      = [
    module.v1_resource,
    module.v2_resource
  ]
}

module "layer" {
  source                 = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/layer"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain            = var.x_rw_domain
  connection_type        = "INTERNET"
  target_url             = var.microservice_host
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource

  depends_on = [
    module.v1_resource,
    module.dataset,
  ]
}

module "metadata" {
  source                           = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/metadata"
  api_gateway                      = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain                      = var.x_rw_domain
  connection_type                  = "INTERNET"
  target_url                       = var.microservice_host
  v1_resource                      = module.v1_resource.aws_api_gateway_resource
  v1_dataset_resource              = module.dataset.v1_dataset_resource
  v1_dataset_id_resource           = module.dataset.v1_dataset_id_resource
  v1_dataset_id_layer_resource     = module.layer.v1_dataset_id_layer_resource
  v1_dataset_id_layer_id_resource  = module.layer.v1_dataset_id_layer_id_resource
  v1_dataset_id_widget_resource    = module.widget.v1_dataset_id_widget_resource
  v1_dataset_id_widget_id_resource = module.widget.v1_dataset_id_widget_id_resource
}

module "nexgddp" {
  source                    = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/nexgddp"
  api_gateway               = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain               = var.x_rw_domain
  connection_type           = "INTERNET"
  target_url                = var.microservice_host
  v1_resource               = module.v1_resource.aws_api_gateway_resource
  v1_query_resource         = module.query.v1_query_resource
  v1_download_resource      = module.query.v1_download_resource
  v1_fields_resource        = module.query.v1_fields_resource
  v1_rest_datasets_resource = module.dataset.v1_rest_datasets_resource
  v1_layer_resource         = module.layer.v1_layer_resource
  v1_layer_id_tile_resource = module.gee-tiles.v1_gee_tiles_layer_id_tile_resource
  depends_on                = [
    module.v1_resource,
    module.layer,
    module.gee-tiles
  ]
}

module "proxy" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/proxy"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host

  depends_on = [
    module.v1_resource,
  ]
}

module "query" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/query"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  depends_on      = [
    module.v1_resource
  ]
}

module "quicc" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/quicc"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  depends_on      = [
    module.v1_resource
  ]
}

module "rw-lp" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/rw-lp"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "resource-watch-manager" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/resource-watch-manager"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "salesforce-connector" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/salesforce-connector"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "story" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/story"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "subscriptions" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/subscriptions"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "task-executor" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/task-executor"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "true-color-tiles" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/true-color-tiles"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  connection_type = "INTERNET"
  target_url      = var.microservice_host
}

module "viirs-fires" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/viirs-fires"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v1_resource     = module.v1_resource.aws_api_gateway_resource
  v2_resource     = module.v2_resource.aws_api_gateway_resource
}

module "vocabulary" {
  source                           = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/vocabulary"
  api_gateway                      = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain                      = var.x_rw_domain
  connection_type                  = "INTERNET"
  target_url                       = var.microservice_host
  v1_resource                      = module.v1_resource.aws_api_gateway_resource
  v1_dataset_resource              = module.dataset.v1_dataset_resource
  v1_dataset_id_resource           = module.dataset.v1_dataset_id_resource
  v1_dataset_id_layer_resource     = module.layer.v1_dataset_id_layer_resource
  v1_dataset_id_layer_id_resource  = module.layer.v1_dataset_id_layer_id_resource
  v1_dataset_id_widget_resource    = module.widget.v1_dataset_id_widget_resource
  v1_dataset_id_widget_id_resource = module.widget.v1_dataset_id_widget_id_resource
}

module "webshot" {
  source          = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/webshot"
  api_gateway     = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain     = var.x_rw_domain
  connection_type = "INTERNET"
  target_url      = var.microservice_host
  v1_resource     = module.v1_resource.aws_api_gateway_resource
}

module "widget" {
  source                 = "../terraform-k8s-infrastructure/modules/k8s_microservice_routing/widget"
  api_gateway            = aws_api_gateway_rest_api.rw_api_gateway
  x_rw_domain            = var.x_rw_domain
  connection_type        = "INTERNET"
  target_url             = var.microservice_host
  v1_resource            = module.v1_resource.aws_api_gateway_resource
  v1_dataset_id_resource = module.dataset.v1_dataset_id_resource

  depends_on = [
    module.v1_resource,
    module.dataset,
  ]
}
