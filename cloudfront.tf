# ---------------------------------------------
# CloudFront cache distribution
# ---------------------------------------------
resource "aws_cloudfront_distribution" "cf" {
  enabled         = true
  is_ipv6_enabled = true
  comment         = "cache distribution"
  price_class     = "PriceClass_All"

  origin {
    domain_name = aws_lb.alb.dns_name
    origin_id   = aws_lb.alb.dns_name

    custom_origin_config {
      origin_protocol_policy = "match-viewer"
      origin_ssl_protocols   = ["TLSv1.2"]
      http_port              = 80
      https_port             = 443
    }
  }

  default_cache_behavior {
    allowed_methods = ["HEAD", "OPTIONS", "GET", "PUT", "POST", "DELETE", "PATCH"]
    cached_methods  = ["HEAD", "OPTIONS", "GET"]
    compress        = true

    forwarded_values {
      query_string = true
      cookies {
        forward = "all"
      }
    }

    target_origin_id       = aws_lb.alb.dns_name
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  aliases = ["tasty-log.site", "*.tasty-log.site"]

  viewer_certificate {
    # cloudfront_default_certificate = true
    acm_certificate_arn      = "arn:aws:acm:us-east-1:553457224232:certificate/6e456540-7ce0-4ffa-82bd-4b231515c121"
    minimum_protocol_version = "TLSv1.2_2021"
    ssl_support_method       = "sni-only"
  }

  lifecycle {
    ignore_changes = [
       default_cache_behavior,
       ordered_cache_behavior,
    ]
  }
}
