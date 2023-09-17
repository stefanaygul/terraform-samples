# creating A record for domain:
resource "aws_route53_record" "websiteurl" {
  name    = "dev-app.example.com"
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_dist.domain_name
    zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
    evaluate_target_health = true
  }
}