############################
## Cloud Front Distribution
############################

//resource "aws_cloudfront_origin_access_identity" "tiles" {}

resource "aws_cloudfront_distribution" "ingress_load_balancer" {

  aliases = var.aliases

  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"

  origin {
    domain_name = var.core_origin.domain_name
    origin_id = var.core_origin.origin_id

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "https-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  # send all uncached URIs to tile cache app
  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = true
    default_ttl            = 86400 # 24h
    max_ttl                = 86400 # 24h
    min_ttl                = 0
    smooth_streaming       = false
    target_origin_id       = "dynamic"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string            = true
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }


  # Latest default layers need to be rerouted and cache headers need to be rewritten
  # This cache bahavior sends the requests to a lambda@edge function which looks up the latest version
  # and then returns a 307 with the correct version number.
  # Responses are cached for 6 hours
  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods         = ["GET", "HEAD"]
    compress               = false
    default_ttl            = 21600 # 6h
    max_ttl                = 21600 # 6h
    min_ttl                = 0
    path_pattern           = "*/latest/*"
    smooth_streaming       = false
    target_origin_id       = "static"
    trusted_signers        = []
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }

    lambda_function_association {
      event_type   = "viewer-request"
      include_body = false
      lambda_arn   = aws_lambda_function.redirect_latest_tile_cache.qualified_arn
    }

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = var.certificate_arn
    cloudfront_default_certificate = false
    minimum_protocol_version       = "TLSv1.1_2016"
    ssl_support_method             = "sni-only"
  }
}

#########################
## IAM
#########################

data "template_file" "create_cloudfront_invalidation" {
  template = file("${path.root}/templates/iam_policy_create_cloudfront_invalidation.json.tmpl")
  vars = {
    cloudfront_arn = aws_cloudfront_distribution.tiles.arn
  }
}

resource "aws_iam_policy" "create_cloudfront_invalidation" {
  name   = "${var.project}-create_cloudfront_invalidation${var.name_suffix}"
  policy = data.template_file.create_cloudfront_invalidation.rendered

}

##################
## Logging
##################


data "aws_regions" "current" {
  all_regions = true
}


resource "aws_cloudwatch_log_group" "lambda_redirect_latest" {
  count = length(tolist(data.aws_regions.current.names))

  name              = "/aws/lambda/${tolist(data.aws_regions.current.names)[count.index]}.${var.project}-redirect_latest_tile_cache${var.name_suffix}"
  retention_in_days = var.log_retention
}

resource "aws_cloudwatch_log_group" "redirect_s3_404" {
  count = length(tolist(data.aws_regions.current.names))

  name              = "/aws/lambda/${tolist(data.aws_regions.current.names)[count.index]}.${var.project}-redirect_s3_404${var.name_suffix}"
  retention_in_days = var.log_retention
}

resource "aws_cloudwatch_log_group" "response_header_cache_control" {
  count = length(tolist(data.aws_regions.current.names))

  name              = "/aws/lambda/${tolist(data.aws_regions.current.names)[count.index]}.${var.project}-response_header_cache_control${var.name_suffix}"
  retention_in_days = var.log_retention
}
