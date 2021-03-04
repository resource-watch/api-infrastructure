resource "kubernetes_service" "document_adapter_service" {
  metadata {
    name = "document-adapter"

  }
  spec {
    selector = {
      name = "document-adapter"
    }
    port {
      port        = 30521
      node_port   = 30521
      target_port = 5000
    }

    type = "NodePort"
  }
}


resource "aws_lb_listener" "document_adapter_nlb_listener" {
  load_balancer_arn = var.load_balancer.arn
  port              = 30521
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.document_adapter_lb_target_group.arn
  }
}

resource "aws_lb_target_group" "document_adapter_lb_target_group" {
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
  count = length(var.eks_asg_names)

  autoscaling_group_name = var.eks_asg_names[count.index]
  alb_target_group_arn   = aws_lb_target_group.document_adapter_lb_target_group.arn
}

// /v1/query
data "aws_api_gateway_resource" "query_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/query"
}

// /v1
data "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1"
}

// /v1/download
data "aws_api_gateway_resource" "download_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/download"
}

// /v1/fields
data "aws_api_gateway_resource" "fields_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/fields"
}

// /v1/dataset/{datasetId}
data "aws_api_gateway_resource" "dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  path        = "/v1/dataset/{datasetId}"
}

// /v1/query/csv
resource "aws_api_gateway_resource" "query_csv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.query_resource.id
  path_part   = "csv"
}

// /v1/query/csv/{datasetId}
resource "aws_api_gateway_resource" "query_csv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_csv_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/tsv
resource "aws_api_gateway_resource" "query_tsv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.query_resource.id
  path_part   = "tsv"
}

// /v1/query/tsv/{datasetId}
resource "aws_api_gateway_resource" "query_tsv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_tsv_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/json
resource "aws_api_gateway_resource" "query_json_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.query_resource.id
  path_part   = "json"
}

// /v1/query/json/{datasetId}
resource "aws_api_gateway_resource" "query_json_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_json_resource.id
  path_part   = "{datasetId}"
}

// /v1/query/xml
resource "aws_api_gateway_resource" "query_xml_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.query_resource.id
  path_part   = "xml"
}

// /v1/query/xml/{datasetId}
resource "aws_api_gateway_resource" "query_xml_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.query_xml_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/csv
resource "aws_api_gateway_resource" "download_csv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.download_resource.id
  path_part   = "csv"
}

// /v1/download/csv/{datasetId}
resource "aws_api_gateway_resource" "download_csv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_csv_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/tsv
resource "aws_api_gateway_resource" "download_tsv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.download_resource.id
  path_part   = "tsv"
}

// /v1/download/tsv/{datasetId}
resource "aws_api_gateway_resource" "download_tsv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_tsv_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/json
resource "aws_api_gateway_resource" "download_json_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.download_resource.id
  path_part   = "json"
}

// /v1/download/json/{datasetId}
resource "aws_api_gateway_resource" "download_json_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_json_resource.id
  path_part   = "{datasetId}"
}

// /v1/download/xml
resource "aws_api_gateway_resource" "download_xml_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.download_resource.id
  path_part   = "xml"
}

// /v1/download/xml/{datasetId}
resource "aws_api_gateway_resource" "download_xml_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.download_xml_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/csv
resource "aws_api_gateway_resource" "fields_csv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.fields_resource.id
  path_part   = "csv"
}

// /v1/fields/csv/{datasetId}
resource "aws_api_gateway_resource" "fields_csv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_csv_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/tsv
resource "aws_api_gateway_resource" "fields_tsv_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.fields_resource.id
  path_part   = "tsv"
}

// /v1/fields/tsv/{datasetId}
resource "aws_api_gateway_resource" "fields_tsv_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_tsv_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/json
resource "aws_api_gateway_resource" "fields_json_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.fields_resource.id
  path_part   = "json"
}

// /v1/fields/json/{datasetId}
resource "aws_api_gateway_resource" "fields_json_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_json_resource.id
  path_part   = "{datasetId}"
}

// /v1/fields/xml
resource "aws_api_gateway_resource" "fields_xml_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.fields_resource.id
  path_part   = "xml"
}

// /v1/fields/xml/{datasetId}
resource "aws_api_gateway_resource" "fields_xml_dataset_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.fields_xml_resource.id
  path_part   = "{datasetId}"
}

// /v1/dataset/{datasetId}/concat
resource "aws_api_gateway_resource" "dataset_id_concat_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "concat"
}

// /v1/dataset/{datasetId}/reindex
resource "aws_api_gateway_resource" "dataset_id_reindex_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "reindex"
}

// /v1/dataset/{datasetId}/append
resource "aws_api_gateway_resource" "dataset_id_append_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "append"
}

// /v1/dataset/{datasetId}/data-overwrite
resource "aws_api_gateway_resource" "dataset_id_data_overwrite_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.dataset_id_resource.id
  path_part   = "data-overwrite"
}

// /v1/doc-dataset
resource "aws_api_gateway_resource" "doc_dataset_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = data.aws_api_gateway_resource.v1_resource.id
  path_part   = "doc-dataset"
}

// /v1/doc-dataset/{provider}
resource "aws_api_gateway_resource" "doc_dataset_provider_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.doc_dataset_resource.id
  path_part   = "{provider}"
}

// /v1/doc-dataset/{provider}/{id}
resource "aws_api_gateway_resource" "doc_dataset_provider_id_resource" {
  rest_api_id = var.api_gateway.id
  parent_id   = aws_api_gateway_resource.doc_dataset_provider_resource.id
  path_part   = "{id}"
}

module "document_adapter_get_query_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_csv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/query/csv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_query_csv_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_csv_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/query/csv/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_query_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/query/json/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_query_json_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_json_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/query/json/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_query_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/query/tsv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_query_tsv_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_tsv_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/query/tsv/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_query_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/query/xml/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_query_xml_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.query_xml_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/query/xml/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_download_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_csv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/download/csv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_download_csv_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_csv_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/download/csv/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_download_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/download/json/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_download_json_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_json_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/download/json/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_download_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/download/tsv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_download_tsv_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_tsv_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/download/tsv/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_download_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/download/xml/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_download_xml_dataset_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.download_xml_dataset_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/download/xml/{datasetId}"
  vpc_link     = var.vpc_link
}

module "document_adapter_get_fields_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_csv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/fields/csv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_get_fields_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/fields/json/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_get_fields_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/fields/tsv/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_get_fields_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org:30521/api/v1/document/fields/xml/{datasetId}"
  vpc_link       = var.vpc_link
}

module "document_adapter_post_dataset_id_concat" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_concat_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{datasetId}/concat"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_reindex" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_reindex_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{datasetId}/reindex"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_append" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_append_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{datasetId}/append"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_dataset_id_data_overwrite" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.dataset_id_data_overwrite_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{datasetId}/data-overwrite"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}

module "document_adapter_post_doc_dataset_provider" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.doc_dataset_provider_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{provider}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}


module "document_adapter_post_doc_dataset_provider_id" {
  source       = "../endpoint"
  api_gateway  = var.api_gateway
  api_resource = aws_api_gateway_resource.doc_dataset_provider_id_resource
  method       = "POST"
  uri          = "http://api.resourcewatch.org:30521/api/v1/document/{provider}/{id}"
  vpc_link     = var.vpc_link
  endpoint_request_parameters = ["datasetId"]
}
