variable "name" {
  type        = string
  description = "Name of the canary"
}

variable "s3_artifact_location" {
  type        = string
  description = "Location in Amazon S3 where Synthetics stores artifacts from the test runs of this canary"
}

variable "execution_role_arn" {
  type        = string
  description = "ARN of the IAM role to be used to run the canary"
}

variable "hostname" {
  type        = string
  description = "Hostname of the endpoint to test"
}

variable "path" {
  type        = string
  description = "Path of the endpoint to test"
}

variable "template_relative_path" {
  type        = string
  default     = "canary-lambda.js.tpl"
  description = "Path to the lambda function template, relative to the module's path"
}

variable "verb" {
  type        = string
  description = "HTTP verb of the endpoint to test"
}

variable "hostname_secret_id" {
  type        = string
  description = "AWS Secret Manager secret id containing the hostname from where the test request originates"
}

variable "token_secret_id" {
  type        = string
  description = "AWS Secret Manager secret id containing the auth token"
}

variable "schedule_expression" {
  type        = string
  description = "Expression defining how often the canary runs"
}

variable "sns_topic_arn" {
  type = string
  description = "ARN of the AWS SNS topic to use in case of alert"
}
