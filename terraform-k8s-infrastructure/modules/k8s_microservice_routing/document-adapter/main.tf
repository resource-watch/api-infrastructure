resource "kubernetes_service" "document_adapter_service" {
  metadata {
    name = "document-adapter"
    annotations = {
      "service.beta.kubernetes.io/aws-load-balancer-type"                     = "nlb"
      "service.beta.kubernetes.io/aws-load-balancer-internal"                 = "true"
      "service.beta.kubernetes.io/aws-load-balancer-additional-resource-tags" = "service=document-adapter"
    }
  }
  spec {
    selector = {
      name = "document-adapter"
    }
    port {
      port        = 80
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

data "aws_lb" "document_adapter_lb" {
  name = split("-", kubernetes_service.document_adapter_service.status.0.load_balancer.0.ingress.0.hostname).0

  depends_on = [
    kubernetes_service.document_adapter_service
  ]
}

resource "aws_api_gateway_vpc_link" "document_adapter_lb_vpc_link" {
  name        = "Document Adapter LB VPC link"
  description = "VPC link to the document_adapter service load balancer"
  target_arns = [data.aws_lb.document_adapter_lb.arn]

  lifecycle {
    create_before_destroy = true
  }
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
  uri            = "http://api.resourcewatch.org/api/v1/document/query/csv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_query_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_csv_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/csv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_query_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/json/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_query_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_json_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/json/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_query_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/tsv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_query_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_tsv_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/tsv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_query_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/xml/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_query_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.query_xml_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/query/xml/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_download_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_csv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/csv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_download_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_csv_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/csv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_download_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/json/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_download_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_json_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/json/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_download_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/tsv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_download_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_tsv_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/tsv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_download_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/xml/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_download_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.download_xml_dataset_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/download/xml/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_fields_csv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_csv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/fields/csv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_fields_json_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_json_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/fields/json/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_fields_tsv_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_tsv_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/fields/tsv/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_get_fields_xml_dataset_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.fields_xml_dataset_id_resource
  method         = "GET"
  backend_method = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/fields/xml/{datasetId}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_dataset_id_concat" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.dataset_id_concat_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{datasetId}/concat"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_dataset_id_reindex" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.dataset_id_reindex_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{datasetId}/reindex"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_dataset_id_append" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.dataset_id_append_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{datasetId}/append"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_dataset_id_data_overwrite" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.dataset_id_data_overwrite_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{datasetId}/data-overwrite"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}

module "document_adapter_post_doc_dataset_provider" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.doc_dataset_provider_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{provider}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}


module "document_adapter_post_doc_dataset_provider_id" {
  source         = "../endpoint"
  api_gateway    = var.api_gateway
  api_resource   = aws_api_gateway_resource.doc_dataset_provider_id_resource
  method         = "POST"
  uri            = "http://api.resourcewatch.org/api/v1/document/{provider}/{id}"
  vpc_link       = aws_api_gateway_vpc_link.document_adapter_lb_vpc_link
}
