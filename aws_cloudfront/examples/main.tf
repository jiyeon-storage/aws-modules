provider "aws" {
  region = "ap-northeast-2"
}

module "cloudfront" {
  source = "../"

  prefix  = "test"
  team    = "test"
  env     = "test"
  purpose = "cdn"

  aliases = ["${local.subdomain}.${local.root_domain}"]

  comment             = "My awesome CloudFront"
  enabled             = true
  is_ipv6_enabled     = false
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  # When you enable additional metrics for a distribution, CloudFront sends up to 8 metrics to CloudWatch in the US East (N. Virginia) Region.
  # This rate is charged only once per month, per metric (up to 8 metrics per distribution).
  create_monitoring_subscription = true

  create_origin_access_identity = true
  origin_access_identities = {
    s3_bucket_one = "My awesome CloudFront can access"
  }

  #logging_config = {
  #  bucket = module.log_bucket.s3_bucket_bucket_domain_name
  #  prefix = "cloudfront"
  #}

  origin = {
    cache = {
      domain_name = "test-cache.${local.root_domain}"
      origin_id   = "cache"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }
    }
  }

  default_cache_behavior = {
    target_origin_id       = "cache"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD"]
    compress               = false
    query_string           = false
    use_forwarded_values   = false

    #캐시 정책 ( Managed_CachingOptimized )
    cache_policy_id = "658327ea-f89d-4fab-a63d-7e88639e58f6"
    # 원본 요청 정책 ( CORS-S3Origin )
    origin_request_policy_id = "88a5eaf4-2fd4-4709-b370-b4c650ea3fcf"

  }

}
