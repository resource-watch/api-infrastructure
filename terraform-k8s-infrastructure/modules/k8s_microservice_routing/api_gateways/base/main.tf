resource "aws_api_gateway_method_settings" "aws_api_gateway_method_settings" {
  rest_api_id = aws_api_gateway_rest_api.aws_api_gateway_rest_api.id
  stage_name  = aws_api_gateway_deployment.prod.stage_name
  method_path = "*/*"

  settings {
    # Enable CloudWatch logging and metrics
    metrics_enabled    = true
    data_trace_enabled = true
    logging_level      = "INFO"

    # Limit the rate of calls to prevent abuse and unwanted charges
    throttling_rate_limit  = 100
    throttling_burst_limit = 50
  }
}

resource "aws_api_gateway_rest_api" "aws_api_gateway_rest_api" {
  name        = "rw-api-${replace(var.dns_prefix, " ", "-")}-${var.name_suffix}"
  description = "API Gateway for the RW API ${var.dns_prefix} ${var.name_suffix} cluster"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_deployment" "prod" {
  rest_api_id = aws_api_gateway_rest_api.aws_api_gateway_rest_api.id
  stage_name  = "prod"

  triggers = {
    redeployment = sha1(join(",", var.endpoint_list))
  }

  lifecycle {
    create_before_destroy = true
  }
}