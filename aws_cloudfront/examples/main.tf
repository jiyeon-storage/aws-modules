module "cloudfront" {
  source = "../../../module/aws/cdn"

  aliases = ["${local.subdomain}.${local.domain_name}"]

  prefix  = local.prefix
  env     = local.env
  team    = local.team
  purpose = local.purpose

  comment             = "CloudFront TEST"
  enabled             = true
  staging             = false
  http_version        = "http2and3"
  is_ipv6_enabled     = true
  price_class         = "PriceClass_All"
  retain_on_delete    = false
  wait_for_deployment = false

  continuous_deployment_policy_id = null

  create_monitoring_subscription = true

  # CloudFront가 S3 콘텐츠에 안전하게 접근하도록 OAI(Origin Access Identity) 설정 - 요즘에는 안쓰는 방식
  create_origin_access_identity = false
  # origin_access_identities = {
  #   s3_bucket_one = "CloudFront TEST"
  # }

  # CloudFront가 S3 콘텐츠에 안전하게 접근하도록 OAC(Origin Access Control)설정 - 권장하는 방식
  create_origin_access_control = true
  origin_access_control = {
    s3_oac = {
      description      = "CloudFront access to S3"
      origin_type      = "s3"
      signing_behavior = "always"
      signing_protocol = "sigv4"
    }
  }
  # CloudFront 배포에서 VPC 내부의 리소스를 오리진(origin)으로 사용하는 설정
  create_vpc_origin = false
  # vpc_origin = {
  #   ec2_vpc_origin = {
  #     name                   = random_pet.this.id
  #     arn                    = module.ec2.arn
  #     http_port              = 80
  #     https_port             = 443
  #     origin_protocol_policy = "http-only"
  #     origin_ssl_protocols = {
  #       items    = ["TLSv1.2"]
  #       quantity = 1
  #     }
  #   }
  # }

  logging_config = {
    bucket = module.log_bucket.s3_bucket_bucket_domain_name
    prefix = "cloudfront"
  }

  origin = {
    appsync = {
      domain_name = "appsync.${local.domain_name}"
      custom_origin_config = {
        http_port              = 80
        https_port             = 443
        origin_protocol_policy = "match-viewer"
        origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
      }

      custom_header = [
        {
          name  = "X-Forwarded-Scheme"
          value = "https"
        },
        {
          name  = "X-Frame-Options"
          value = "SAMEORIGIN"
        }
      ]

      origin_shield = {
        enabled              = true
        origin_shield_region = "us-east-1"
      }
    }
    # 예전 방식
    # s3_one = {
    #   domain_name = module.s3_one.s3_bucket_bucket_regional_domain_name
    #   s3_origin_config = {
    #     origin_access_identity = "s3_bucket_one"
    #   }
    # }

    # 권장되는 방식
    s3_oac = { 
      domain_name           = module.s3_one.s3_bucket_bucket_regional_domain_name
      origin_access_control = "s3_oac"
    }
    
    # PC 내 EC2 인스턴스를 오리진으로 사용할때
    # ec2_vpc_origin = {
    #   domain_name = module.ec2.private_dns
    #   vpc_origin_config = {
    #     vpc_origin = "ec2_vpc_origin" # key in `vpc_origin`
    #   }
    # }
  }

  origin_group = {
    group_one = {
      failover_status_codes      = [403, 404, 500, 502]
      primary_member_origin_id   = "appsync"
      secondary_member_origin_id = "s3_oac"
    }
  }

  default_cache_behavior = {
    target_origin_id       = "appsync"
    viewer_protocol_policy = "allow-all"
    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]

    use_forwarded_values = false

    cache_policy_id            = "b2884449-e4de-46a7-ac36-70bc7f1ddd6d"
    response_headers_policy_id = "67f7725c-6f97-4210-82d7-5512b31e9d03"

    # lambda_function_association = {

    #   viewer-request = {
    #     lambda_arn   = module.lambda_function.lambda_function_qualified_arn
    #     include_body = true
    #   }

    #   origin-request = {
    #     lambda_arn = module.lambda_function.lambda_function_qualified_arn
    #   }
    # }
  }

  ordered_cache_behavior = [
    {
      path_pattern           = "/static/*"
      target_origin_id       = "s3_oac"
      viewer_protocol_policy = "redirect-to-https"

      allowed_methods = ["GET", "HEAD", "OPTIONS"]
      cached_methods  = ["GET", "HEAD"]

      use_forwarded_values = false

      cache_policy_name            = "Managed-CachingOptimized"
      origin_request_policy_name   = "Managed-UserAgentRefererHeaders"
      response_headers_policy_name = "Managed-SimpleCORS"

      # function_association = {
      #   viewer-request = {
      #     function_arn = aws_cloudfront_function.example.arn
      #   }

      #   viewer-response = {
      #     function_arn = aws_cloudfront_function.example.arn
      #   }
      # }
    },
    # {
    #   path_pattern           = "/static-no-policies/*"
    #   target_origin_id       = "s3_one"
    #   viewer_protocol_policy = "redirect-to-https"

    #   allowed_methods = ["GET", "HEAD", "OPTIONS"]
    #   cached_methods  = ["GET", "HEAD"]

    #   compress     = true
    #   query_string = true
    #  },
    # {
    #   path_pattern           = "/vpc-origin/*"
    #   target_origin_id       = "ec2_vpc_origin"
    #   viewer_protocol_policy = "redirect-to-https"

    #   allowed_methods = ["GET", "HEAD", "OPTIONS"]
    #   cached_methods  = ["GET", "HEAD"]
    # }

  ]

  viewer_certificate = {
    acm_certificate_arn = local.acm_certificate_arn
    ssl_support_method  = "sni-only"
  }

  custom_error_response = [{
    error_code         = 404
    response_code      = 404
    response_page_path = "/errors/404.html"
    }, {
    error_code         = 403
    response_code      = 403
    response_page_path = "/errors/403.html"
  }]

  geo_restriction = {
    restriction_type = "whitelist"
    locations        = ["NO", "UA", "US", "GB"]
  }

}

######
# ACM
######

data "aws_route53_zone" "this" {
  name = local.domain_name
}

module "acm" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 4.0"

  domain_name               = local.domain_name
  zone_id                   = data.aws_route53_zone.this.id
  subject_alternative_names = ["${local.subdomain}.${local.domain_name}"]
}

#############
# S3 buckets
#############

data "aws_canonical_user_id" "current" {}
data "aws_cloudfront_log_delivery_canonical_user_id" "cloudfront" {}

module "s3_one" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket        = local.origin_bucket_name
  force_destroy = true
}

module "log_bucket" {
  source  = "terraform-aws-modules/s3-bucket/aws"
  version = "~> 4.0"

  bucket = local.log_bucket_name

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  grant = [{
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_canonical_user_id.current.id
    }, {
    type       = "CanonicalUser"
    permission = "FULL_CONTROL"
    id         = data.aws_cloudfront_log_delivery_canonical_user_id.cloudfront.id
  }]
  force_destroy = true
}

#############################################
# Using packaged function from Lambda module
#############################################

# locals {
#   package_url = "https://raw.githubusercontent.com/terraform-aws-modules/terraform-aws-lambda/master/examples/fixtures/python3.8-zip/existing_package.zip"
#   downloaded  = "downloaded_package_${md5(local.package_url)}.zip"
# }

# resource "null_resource" "download_package" {
#   triggers = {
#     downloaded = local.downloaded
#   }

#   provisioner "local-exec" {
#     command = "curl -L -o ${local.downloaded} ${local.package_url}"
#   }
# }

# module "lambda_function" {
#   source  = "terraform-aws-modules/lambda/aws"
#   version = "~> 7.0"

#   function_name = "${random_pet.this.id}-lambda"
#   description   = "My awesome lambda function"
#   handler       = "index.lambda_handler"
#   runtime       = "python3.8"

#   publish        = true
#   lambda_at_edge = true

#   create_package         = false
#   local_existing_package = local.downloaded

#   # @todo: Missing CloudFront as allowed_triggers?

#   #    allowed_triggers = {
#   #      AllowExecutionFromAPIGateway = {
#   #        service = "apigateway"
#   #        arn     = module.api_gateway.apigatewayv2_api_execution_arn
#   #      }
#   #    }
# }

##########
# Route53
##########

module "records" {
  source  = "terraform-aws-modules/route53/aws//modules/records"
  version = "~> 2.0"

  zone_id = data.aws_route53_zone.this.zone_id

  records = [
    {
      name = local.subdomain
      type = "A"
      alias = {
        name    = module.cloudfront.cloudfront_distribution_domain_name
        zone_id = module.cloudfront.cloudfront_distribution_hosted_zone_id
      }
    },
  ]
}

#########################################
# S3 bucket policy
#########################################

data "aws_iam_policy_document" "s3_policy" {
  # Origin Access Identities
  # statement {
  #   actions   = ["s3:GetObject"]
  #   resources = ["${module.s3_one.s3_bucket_arn}/static/*"]

  #   principals {
  #     type        = "AWS"
  #     identifiers = module.cloudfront.cloudfront_origin_access_identity_iam_arns
  #   }
  # }

  # Origin Access Controls
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${module.s3_one.s3_bucket_arn}/static/*"]

    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }

    condition {
      test     = "StringEquals"
      variable = "aws:SourceArn"
      values   = [module.cloudfront.cloudfront_distribution_arn]
    }
  }
}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = module.s3_one.s3_bucket_id
  policy = data.aws_iam_policy_document.s3_policy.json
}

#########################################
# CloudFront function
#########################################

# resource "aws_cloudfront_function" "example" {
#   name    = "example-${random_pet.this.id}"
#   runtime = "cloudfront-js-1.0"
#   code    = file("${path.module}/example-function.js")
# }

#########################################
# EC2 instance for CloudFront VPC origin
#########################################

# data "aws_ami" "al2023" {
#   most_recent = true
#   owners      = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-2023*-x86_64"]
#   }
# }

# module "ec2" {
#   source  = "terraform-aws-modules/ec2-instance/aws"
#   version = "~> 5.0"

#   ami = data.aws_ami.al2023.id
# }

########
# Extra
########

# resource "random_pet" "this" {
#   length = 2
# }