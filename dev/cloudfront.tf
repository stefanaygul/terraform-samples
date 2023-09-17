#creating OAI :
resource "aws_cloudfront_origin_access_identity" "oai" {
  comment = "OAI for ${var.domain_name}"
}


# cloudfront terraform - creating AWS Cloudfront distribution :
resource "aws_cloudfront_distribution" "cf_dist" {
  enabled             = true
  aliases             = ["dev-app.example.com"]
  default_root_object = "index.html"
  origin {
    domain_name = aws_s3_bucket.bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.bucket.id
    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.oai.cloudfront_access_identity_path
    }
  }

  custom_error_response {
    error_caching_min_ttl = "0"
    error_code            = "403"
    response_code         = "200"
    response_page_path    = "/index.html"
  }
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD", "OPTIONS", "PUT", "POST", "PATCH", "DELETE"]
    cached_methods         = ["GET", "HEAD", "OPTIONS"]
    target_origin_id       = aws_s3_bucket.bucket.id
    viewer_protocol_policy = "redirect-to-https" # other options - https only, http
    forwarded_values {
      headers      = []
      query_string = true
      cookies {
        forward = "all"
      }
    }
  }
  restrictions {
    geo_restriction {
      restriction_type = "none"
      locations        = []
    }
  }
  tags = {
    "Project"   = "ninja"
    "ManagedBy" = "Terraform"
  }
  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.amazon_issued.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2018"
  }
}