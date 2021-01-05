
# Create the Lambda function
resource "aws_lambda_function" "eks_scaling" {
  function_name = "eks_scaling"
  description   = "Upscale or downscale EKS cluster"
  handler       = "eks_scaling.lambda_handler"
  runtime       = var.lambda_eks_scaling_python_runtime

  role        = aws_iam_role.lambda_exec_role.arn
  memory_size = 128
  timeout     = 300

  source_code_hash = data.archive_file.lambda_eks_scaling.output_base64sha256
  filename         = data.archive_file.lambda_eks_scaling.output_path
}

# Create a log group for the Lambda function
resource "aws_cloudwatch_log_group" "eks_scaling_log_group" {
  name              = "/aws/lambda/eks_scaling"
  retention_in_days = var.log_retention
}

# Create the Cloudwatch event rule for upscaling.
# Every upscaled config variable (e.g. apps_node_group_min_size_upscaled)
# has a default value of -1 as a sentinel. If a value for that variable is
# not provided, it will just take the corresponding downscaled value.
resource "aws_cloudwatch_event_rule" "upscale_eks_cluster" {
  name                = "upscale-eks-cluster"
  description         = "Upscale EKS cluster at 10pm"
  schedule_expression = var.cw_upscale_crontab
}

# Create the Cloudwatch event rule for downscaling
resource "aws_cloudwatch_event_rule" "downscale_eks_cluster" {
  name                = "downscale-eks-cluster"
  description         = "Downscale EKS cluster at midnight"
  schedule_expression = var.cw_downscale_crontab
}

# Associate the event rules with the Lambda function
resource "aws_cloudwatch_event_target" "upscale_eks_cluster" {
  rule      = aws_cloudwatch_event_rule.upscale_eks_cluster.name
  target_id = "lambda"
  arn       = aws_lambda_function.eks_scaling.arn
  input     = <<EOF
{
  "eks_cluster_name": "${var.eks_cluster_name}",
  "nodegroup_config": [
    {
      "nodegroup_name": "apps-node-group",
      "scaling_config": {
        "minSize": ${var.apps_node_group_min_size_upscaled != -1 ? var.apps_node_group_min_size_upscaled : var.apps_node_group_min_size},
        "maxSize": ${var.apps_node_group_max_size_upscaled != -1 ? var.apps_node_group_max_size_upscaled : var.apps_node_group_max_size},
        "desiredSize": ${var.apps_node_group_desired_size_upscaled != -1 ? var.apps_node_group_desired_size_upscaled : var.apps_node_group_desired_size}
      }
    },
    {
      "nodegroup_name": "gfw-node-group",
      "scaling_config": {
        "minSize": ${var.gfw_node_group_min_size_upscaled != -1 ? var.gfw_node_group_min_size_upscaled : var.gfw_node_group_min_size},
        "maxSize": ${var.gfw_node_group_max_size_upscaled != -1 ? var.gfw_node_group_max_size_upscaled : var.gfw_node_group_max_size},
        "desiredSize": ${var.gfw_node_group_desired_size_upscaled != -1 ? var.gfw_node_group_desired_size_upscaled : var.gfw_node_group_desired_size}
      }
    }
  ]
}
EOF
}

resource "aws_cloudwatch_event_target" "downscale_eks_cluster" {
  rule      = aws_cloudwatch_event_rule.downscale_eks_cluster.name
  target_id = "lambda"
  arn       = aws_lambda_function.eks_scaling.arn
  input     = <<EOF
{
  "eks_cluster_name": "${var.eks_cluster_name}",
  "scaling_config": {
    "apps-node-group": {
      "minSize": ${var.apps_node_group_min_size},
      "maxSize": ${var.apps_node_group_max_size},
      "desiredSize": ${var.apps_node_group_desired_size}
    },
    "gfw-node-group": {
      "minSize": ${var.gfw_node_group_min_size},
      "maxSize": ${var.gfw_node_group_max_size},
      "desiredSize": ${var.gfw_node_group_desired_size}
    }
  }
}
EOF
}

# Give Cloudwatch permission to run the function
resource "aws_lambda_permission" "allow_cloudwatch_upscale_to_call_eks_scaling" {
  statement_id  = "AllowExecutionFromCloudWatchUpscaleEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eks_scaling.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.upscale_eks_cluster.arn
}
resource "aws_lambda_permission" "allow_cloudwatch_downscale_to_call_eks_scaling" {
  statement_id  = "AllowExecutionFromCloudWatchDownscaleEventRule"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.eks_scaling.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.downscale_eks_cluster.arn
}

# Create an IAM role for the Lambda function
resource "aws_iam_role" "lambda_exec_role" {
  name               = "lambda_exec_role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      }
    }
  ]
}
EOF
}

# Create an IAM policy for the Lambda function
resource "aws_iam_policy" "lambda_iam_policy" {
  name   = "lambda_iam_policy"
  policy = data.aws_iam_policy_document.lambda_policy_doc.json
}

# Associate the policy with the function's IAM role
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_iam_policy.arn
  role       = aws_iam_role.lambda_exec_role.name
}
