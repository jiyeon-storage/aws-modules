resource "aws_wafv2_ip_set" "this" {
  for_each = { for k, v in var.ip_set_v2_config : k => v }

  name = format("%s%s-%s-%s-v2-ipset", var.prefix, var.env, var.purpose, each.value.name)

  description        = lookup(each.value, "description", null)
  scope              = lookup(each.value, "scope", "REGIONAL")
  ip_address_version = lookup(each.value, "ip_address_version", "IPV4")
  addresses          = lookup(each.value, "addresses", null)

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-v2-ipset", var.prefix, var.env, var.purpose)
  })
}

resource "aws_wafv2_regex_pattern_set" "this" {
  for_each = { for k, v in var.regex_pattern_set_config : k => v }

  name  = format("%s%s-%s-%s-regex", var.prefix, var.env, var.purpose, each.value.name)
  scope = each.value.scope

  dynamic "regular_expression" {
    for_each = lookup(each.value, "regular_expression_list", null) != null ? each.value.regular_expression_list : []

    content {
      regex_string = regular_expression.value
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-regex", var.prefix, var.env, var.purpose)
  })
}

resource "aws_wafv2_web_acl" "this" {
  name = format("%s-%s-%s-%s-webacl", var.prefix, var.env, var.purpose, var.web_acl_config.name)

  description = "WAFv2 ACL"
  scope       = lookup(var.web_acl_config, "scope", "REGIONAL")

  default_action {
    dynamic "allow" {
      for_each = var.web_acl_config.default_action == "allow" ? [1] : []
      content {}
    }

    dynamic "block" {
      for_each = var.web_acl_config.default_action == "block" ? [1] : []
      content {}
    }
  }

  dynamic "rule" {
    for_each = lookup(var.web_acl_config, "managed_rules", null)

    content {
      name     = format("%s-%s-%s-%s-managedrule", var.prefix, var.env, var.purpose, rule.value.name)
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []
          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []
          content {}
        }
      }

      statement {
        managed_rule_group_statement {
          name        = rule.value.name
          vendor_name = "AWS"

          dynamic "excluded_rule" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value.visibility_config, "cloudwatch_metrics_enabled", true)
        sampled_requests_enabled   = lookup(rule.value.visibility_config, "sampled_requests_enabled", true)
        metric_name                = format("%s-%s-%s-%s-managedrule", var.prefix, var.env, var.purpose, rule.value.name)
      }
    }
  }


  dynamic "rule" {
    for_each = lookup(var.web_acl_config, "rule_groups", {})

    content {
      name     = aws_wafv2_rule_group.this[rule.key].name
      priority = rule.value.priority

      override_action {
        dynamic "none" {
          for_each = rule.value.override_action == "none" ? [1] : []

          content {}
        }

        dynamic "count" {
          for_each = rule.value.override_action == "count" ? [1] : []

          content {}
        }
      }

      statement {
        rule_group_reference_statement {
          arn = aws_wafv2_rule_group.this[rule.key].arn

          dynamic "excluded_rule" {
            for_each = rule.value.excluded_rules
            content {
              name = excluded_rule.value
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value.visibility_config, "cloudwatch_metrics_enabled", true)
        sampled_requests_enabled   = lookup(rule.value.visibility_config, "sampled_requests_enabled", true)
        metric_name                = aws_wafv2_rule_group.this[rule.key].name
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = lookup(var.web_acl_config, "cloudwatch_metrics_enabled", true)
    sampled_requests_enabled   = lookup(var.web_acl_config, "sampled_requests_enabled", true)
    metric_name                = lookup(var.web_acl_config, "name", null)
  }

  tags = merge(local.default_tags, {
    Name = format("%s-%s-%s-v2-webacl", var.prefix, var.env, var.purpose)
  })
}

resource "aws_wafv2_web_acl_association" "this" {
  count = var.alb_arn != null ? 1 : 0

  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

resource "aws_wafv2_web_acl_logging_configuration" "this" {
  log_destination_configs = [aws_cloudwatch_log_group.this.arn, var.log_s3]
  resource_arn            = aws_wafv2_web_acl.this.arn

  redacted_fields {
    dynamic "method" {
      for_each = var.enabled_logging_method ? [1] : []
      content {}
    }
    dynamic "query_string" {
      for_each = var.enabled_logging_query ? [1] : []
      content {}
    }
    dynamic "uri_path" {
      for_each = var.enabled_logging_uri_path ? [1] : []
      content {}
    }
  }
}
