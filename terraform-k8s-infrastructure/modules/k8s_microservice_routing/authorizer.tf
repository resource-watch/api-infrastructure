# Lambda Authorizer
resource "aws_api_gateway_authorizer" "api_key" {
  name                             = "api_key"
  rest_api_id                      = aws_api_gateway_rest_api.rw_api_gateway.id
  type                             = "REQUEST"
  authorizer_uri                   = aws_lambda_function.authorizer.invoke_arn
  authorizer_credentials           = aws_iam_role.invocation_role.arn
  authorizer_result_ttl_in_seconds = 0

  # making sure terraform doesn't require default authorization
  # header (https://github.com/hashicorp/terraform-provider-aws/issues/5845)
  identity_source = ","
}

#resource "aws_lambda_function" "authorizer" {
#  filename      = "api_gateway/api_key_authorizer_lambda.zip"
#  function_name = "api_gateway_authorizer_${var.environment}"
#  runtime       = "python3.8"
#  role          = aws_iam_role.lambda.arn
#  handler       = "lambda_function.handler"
#
#  source_code_hash = filebase64sha256("api_gateway/api_key_authorizer_lambda.zip")
#}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_source"
  output_path = "${path.module}/lambda.zip"
}

resource "aws_lambda_function" "authorizer" {
  filename         = "${path.module}/lambda.zip"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  function_name    = "api_gateway_authorizer_${var.environment}"
  role             = aws_iam_role.lambda.arn
  handler          = "api_key_authorizer_lambda.handler"
  runtime          = "python3.8"
}

resource "aws_iam_role" "invocation_role" {
  name = "api_gateway_auth_invocation_${var.environment}"
  path = "/"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

resource "aws_iam_role_policy" "invocation_policy" {
  name = "default"
  role = aws_iam_role.invocation_role.id

  policy = jsonencode(
    {
      "Version" : "2012-10-17",
      "Statement" : [
        {
          "Action" : "lambda:InvokeFunction",
          "Effect" : "Allow",
          "Resource" : aws_lambda_function.authorizer.arn
        }
      ]
    }
  )
}

resource "aws_iam_role" "lambda" {
  name = "api_gw_authorizer_lambda_${var.environment}"

  assume_role_policy = jsonencode({
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
    Version = "2012-10-17"
  })
}

# Lambda logging
resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/api_gw_authorizer_lambda_${var.environment}"
  retention_in_days = 14
}

# See also the following AWS managed policy: AWSLambdaBasicExecutionRole
resource "aws_iam_policy" "lambda_logging" {
  name        = "lambda_logging"
  path        = "/"
  description = "IAM policy for logging from a lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.lambda.name
  policy_arn = aws_iam_policy.lambda_logging.arn
}

