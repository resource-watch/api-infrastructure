resource "kubernetes_service" "document_adapter_service" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  metadata {
    name = "document"

  }
  spec {
    selector = {
      name = "document"
    }
    port {
      port        = 30521
      node_port   = 30521
      target_port = 4000
    }

    type = "NodePort"
  }
}

locals {
  api_gateway_target_url = var.connection_type == "VPC_LINK" ? data.aws_lb.load_balancer[0].dns_name : var.target_url
}

data "aws_lb" "load_balancer" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  arn = var.vpc_link.target_arns[0]
}

resource "aws_lb_listener" "document_adapter_nlb_listener" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  load_balancer_arn = data.aws_lb.load_balancer[0].arn
  port              = 30521
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.document_adapter_lb_target_group[0].arn
  }
}

resource "aws_lb_target_group" "document_adapter_lb_target_group" {
  count = var.connection_type == "VPC_LINK" ? 1 : 0

  name        = "document-adapter-lb-tg"
  port        = 30521
  protocol    = "TCP"
  target_type = "instance"
  vpc_id      = var.vpc.id

  health_check {
    enabled  = true
    protocol = "TCP"
  }
}

resource "aws_autoscaling_attachment" "asg_attachment_document_adapter" {
  count = var.connection_type == "VPC_LINK" ? length(var.eks_asg_names) : 0

  autoscaling_group_name = var.eks_asg_names[count.index]
  lb_target_group_arn   = aws_lb_target_group.document_adapter_lb_target_group[0].arn
}

// /v1/query/csv
module "query_csv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "csv"
}

// /v1/query/csv/{datasetId}
module "query_csv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_csv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/tsv
module "query_tsv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "tsv"
}

// /v1/query/tsv/{datasetId}
module "query_tsv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_tsv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/json
module "query_json_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "json"
}

// /v1/query/json/{datasetId}
module "query_json_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_json_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/xml
module "query_xml_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_query_resource.id
  path_part   = "xml"
}

// /v1/query/xml/{datasetId}
module "query_xml_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.query_xml_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/csv
module "download_csv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "csv"
}

// /v1/download/csv/{datasetId}
module "download_csv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_csv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/tsv
module "download_tsv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "tsv"
}

// /v1/download/tsv/{datasetId}
module "download_tsv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_tsv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/json
module "download_json_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "json"
}

// /v1/download/json/{datasetId}
module "download_json_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_json_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/xml
module "download_xml_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_download_resource.id
  path_part   = "xml"
}

// /v1/download/xml/{datasetId}
module "download_xml_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.download_xml_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/csv
module "fields_csv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "csv"
}

// /v1/fields/csv/{datasetId}
module "fields_csv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_csv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/tsv
module "fields_tsv_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "tsv"
}

// /v1/fields/tsv/{datasetId}
module "fields_tsv_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_tsv_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/json
module "fields_json_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "json"
}

// /v1/fields/json/{datasetId}
module "fields_json_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_json_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/xml
module "fields_xml_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_fields_resource.id
  path_part   = "xml"
}

// /v1/fields/xml/{datasetId}
module "fields_xml_v1_dataset_id_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.fields_xml_resource.aws_api_gateway_resource.id
  path_part   = "{datasetId}"
}

// /v1/dataset/{datasetId}/concat
module "dataset_id_concat_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "concat"
}

// /v1/dataset/{datasetId}/reindex
module "dataset_id_reindex_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "reindex"
}

// /v1/dataset/{datasetId}/append
module "dataset_id_append_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "append"
}

// /v1/dataset/{datasetId}/data-overwrite
module "dataset_id_data_overwrite_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_dataset_id_resource.id
  path_part   = "data-overwrite"
}

// /v1/doc-datasets
module "doc_datasets_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = var.v1_resource.id
  path_part   = "doc-datasets"
}

// /v1/doc-datasets/{proxy+}
module "doc_datasets_proxy_resource" {
  source      = "../resource"
  rest_api_id = var.api_gateway.id
  parent_id   = module.doc_datasets_resource.aws_api_gateway_resource.id
  path_part   = "{proxy+}"
}

module "document_adapter_get_query_csv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_csv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/csv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_query_csv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_csv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/csv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_query_json_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_json_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/json/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_query_json_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_json_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/json/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_query_tsv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_tsv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/tsv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_query_tsv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_tsv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/tsv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_query_xml_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_xml_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/xml/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_query_xml_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.query_xml_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/query/xml/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_download_csv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_csv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/csv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_download_csv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_csv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/csv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_download_json_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_json_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/json/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_download_json_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_json_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/json/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_download_tsv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_tsv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/tsv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_download_tsv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_tsv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/tsv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_download_xml_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_xml_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/xml/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_download_xml_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.download_xml_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "POST"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/download/xml/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_fields_csv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fields_csv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/fields/csv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_fields_json_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fields_json_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/fields/json/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_fields_tsv_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fields_tsv_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/fields/tsv/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_get_fields_xml_dataset_id" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.fields_xml_v1_dataset_id_resource.aws_api_gateway_resource
  method          = "GET"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/fields/xml/{datasetId}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}

module "document_adapter_post_dataset_id_concat" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_concat_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30521/api/v1/document/{datasetId}/concat"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_reindex" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_reindex_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30521/api/v1/document/{datasetId}/reindex"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_append" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_append_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30521/api/v1/document/{datasetId}/append"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_data_overwrite" {
  source                      = "../endpoint"
  x_rw_domain                 = var.x_rw_domain
  api_gateway                 = var.api_gateway
  api_resource                = module.dataset_id_data_overwrite_resource.aws_api_gateway_resource
  method                      = "POST"
  uri                         = "http://${local.api_gateway_target_url}:30521/api/v1/document/{datasetId}/data-overwrite"
  vpc_link                    = var.vpc_link
  connection_type             = var.connection_type
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_any_doc_datasets_proxy" {
  source          = "../endpoint"
  x_rw_domain     = var.x_rw_domain
  api_gateway     = var.api_gateway
  api_resource    = module.doc_datasets_proxy_resource.aws_api_gateway_resource
  method          = "ANY"
  uri             = "http://${local.api_gateway_target_url}:30521/api/v1/document/{proxy}"
  vpc_link        = var.vpc_link
  connection_type = var.connection_type
}
