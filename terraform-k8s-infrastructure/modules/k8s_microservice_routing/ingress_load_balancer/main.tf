############################
## Cloud Front Distribution
############################

resource "aws_cloudfront_distribution" "ingress_load_balancer" {

  aliases = var.aliases

  enabled         = true
  http_version    = "http2"
  is_ipv6_enabled = true
  price_class     = "PriceClass_All"

  //core
  origin {
    domain_name = var.core_origin
    origin_id = "core_api_gateway"

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

  //misc
  origin {
    domain_name = var.misc_origin
    origin_id = "misc_api_gateway"

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

  //gfw
  origin {
    domain_name = var.gfw_origin
    origin_id = "gfw_api_gateway"

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


  // Cache behavior for the GFW endpoints
  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    // for the time being, we can't cache anything, as we have no way to invalidate cache.
    cached_methods         = []
    compress               = false
    path_pattern           = "*/latest/*"
    target_origin_id       = "static"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string            = true

      cookies {
        forward           = "all"
      }
    }
  }

  // Cache behavior for the core endpoints
  ordered_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    // for the time being, we can't cache anything, as we have no way to invalidate cache.
    cached_methods         = []
    compress               = false
    path_pattern           = join("|", [
      "/gfw-metadata/*",
      "/v1/area/*",
      "/v1/arcgis-proxy/*"
    ])
    target_origin_id       = "static"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method"]
      query_string            = true

      cookies {
        forward           = "all"
      }
    }
  }

  default_cache_behavior {
    allowed_methods        = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    // for the time being, we can't cache anything, as we have no way to invalidate cache.
    cached_methods         = []
    compress               = true
    target_origin_id       = "misc_api_gateway"
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      headers                 = ["Origin", "Access-Control-Request-Headers", "Access-Control-Request-Method", "Authorization"]
      query_string            = true

      cookies {
        forward           = "all"
      }
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
