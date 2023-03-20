provider "aws" {
  region = "ap-northeast-2"
}

provider "random" {}

resource "random_string" "random" {
  length  = 4
  special = false
}

locals {
  visibility_config = {
    cloudwatch_metrics_enabled = true,
    sampled_requests_enabled   = true
  }
}

module "status" {
  source = "../"

  # logging
  logging_retention_in_days = 90

  # web_acl
  web_acl_config = {
    name           = "test"
    scope          = "REGIONAL"
    default_action = "block"
    managed_rules = [
      {
        name            = "AWSManagedRulesCommonRuleSet"
        priority        = 10
        override_action = "none"
        excluded_rules  = []

        visibility_config = local.visibility_config
      },
    ]
    ip_sets = [
      {
        name     = "test-ipset"
        priority = 20
        action   = "allow"

        visibility_config = {
          cloudwatch_metrics_enabled = true
          sampled_requests_enabled   = false
        }
      },
    ]
    # required 
    rule_groups = [
      {
        priority        = 1
        override_action = "none"
        excluded_rules  = []

        visibility_config = local.visibility_config
      },
    ]
    visibility_config = local.visibility_config
  }

  # ip_set
  ip_set_v1_config = []
  ip_set_v2_config = [
    {
      name               = "test"
      description        = "test wafv2 ipset"
      scope              = "REGIONAL"
      ip_address_version = "IPV4"
      addresses          = ["0.0.0.0/0"]
    },
  ]
  # regex_pattern_set 
  regex_pattern_set_config = {
    "test" = {
      name     = "test"
      scope    = "REGIONAL"
      arn      = null
      priority = 50
      action   = "allow"
      regular_expression_list = [
        "^\\/test\\/login1$",
      ]
      regex_pattern_set_reference_statements = [
        {
          field_to_match = {
            method = "uri_path"
          }
          text_transformation = {
            priority = 0
            type     = "NONE"
          }
        }
      ]
      visibility_config = local.visibility_config
    }
    "test2" = {
      name     = "test2"
      scope    = "REGIONAL"
      arn      = null
      priority = 50
      action   = "allow"
      regular_expression_list = [
        "^\\/test\\/login21$",
      ]
      regex_pattern_set_reference_statements = [
        {
          field_to_match = {
            method = "uri_path"
          }
          text_transformation = {
            priority = 0
            type     = "NONE"
          }
        }
      ]
      visibility_config = local.visibility_config
    }
  }

  # rule group
  rule_group_v1_config = []
  rule_group_v2_config = [
    {
      name        = "test"
      description = "test"
      scope       = "REGIONAL"
      capacity    = 100
      priority    = 1

      visibility_config = local.visibility_config

      rules = [
        {
          and_or            = "and"
          name              = "rule-2"
          priority          = 1
          action            = "allow"
          visibility_config = local.visibility_config

          statements = {
            size_constraint_statement = [
              {
                comparison_operator = "LT"
                size                = 4096

                field_to_match = {
                  query_string = {}
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
            regex_pattern_set_reference_statements = [
              {
                regex_set_key = "test2"
                field_to_match = {
                  method = "uri_path"
                }

                text_transformation = {
                  priority = 0
                  type     = "NONE"
                }
              }
            ]
          }
        },
      ]
    },
  ]
}

