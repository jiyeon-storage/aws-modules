resource "aws_wafv2_rule_group" "this" {
  for_each = { for k, v in var.rule_group_v2_config : k => v }

  name = format("%s-%s-%s-%s-rule", var.prefix, var.env, var.purpose, lookup(each.value, "name", null))

  description = lookup(each.value, "description", null)
  scope       = lookup(each.value, "scope", null)
  capacity    = lookup(each.value, "capacity", null)

  visibility_config {
    cloudwatch_metrics_enabled = lookup(each.value["visibility_config"], "description", true)
    sampled_requests_enabled   = lookup(each.value["visibility_config"], "sampled_requests_enabled", true)
    metric_name                = lookup(each.value, "name", null)
  }

  dynamic "rule" {
    for_each = each.value.rules #lookup(each.value, "rules", {})

    content {
      name     = format("%s-%s-%s", var.prefix, rule.value.name, rule.value.priority)
      priority = rule.value.priority

      action {
        dynamic "allow" {
          for_each = rule.value.action == "allow" ? [1] : []

          content {}
        }
        dynamic "block" {
          for_each = rule.value.action == "block" ? [1] : []

          content {}
        }
        dynamic "count" {
          for_each = rule.value.action == "count" ? [1] : []

          content {}
        }
      }

      statement {
        dynamic "and_statement" {
          for_each = rule.value.and_or == "and" ? [1] : []

          content {
            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "size_constraint_statement"])

              content {
                size_constraint_statement {
                  comparison_operator = statement.value.comparison_operator
                  size                = statement.value.size

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "query_string" {
                        for_each = field_to_match.key == "query_string" ? [1] : []

                        content {}
                      }

                      dynamic "method" {
                        for_each = field_to_match.key == "method" ? [1] : []

                        content {}
                      }
                    }
                  }
                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }

            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "byte_match_statements"])

              content {
                byte_match_statement {
                  positional_constraint = statement.value.positional_constraint
                  search_string         = statement.value.search_string

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "all_query_arguments" {
                        for_each = field_to_match.value == "all_query_arguments" ? [1] : []

                        content {}
                      }

                      dynamic "body" {
                        for_each = field_to_match.value == "body" ? [1] : []

                        content {}
                      }

                      dynamic "method" {
                        for_each = field_to_match.value == "method" ? [1] : []

                        content {}
                      }

                      dynamic "query_string" {
                        for_each = field_to_match.value == "query_string" ? [1] : []

                        content {}
                      }

                      dynamic "single_header" {
                        for_each = field_to_match.value == "single_header" ? [1] : []

                        content {
                          name = single_header.value.name
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = field_to_match.value == "single_query_argument" ? [1] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }

                      dynamic "uri_path" {
                        for_each = field_to_match.value == "uri_path" ? [1] : []

                        content {}
                      }
                    }
                  }

                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }

            dynamic "statement" {
              for_each = { for k, v in rule.value.statements : k => v if k == "geo_match_statement" }

              content {
                geo_match_statement {
                  country_codes = statement.value.country_codes
                }
              }
            }

            dynamic "statement" {
              for_each = { for k, v in rule.value.statements : k => v if k == "ip_set_reference_statement" }

              content {
                ip_set_reference_statement {
                  arn = lookup(statement.value, "arn", aws_wafv2_ip_set.this[statement.value.ip_set_key].arn)
                }
              }
            }

            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "regex_pattern_set_reference_statements"])

              content {
                regex_pattern_set_reference_statement {

                  arn = lookup(statement.value, "arn", aws_wafv2_regex_pattern_set.this[statement.value.regex_set_key].arn)

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "all_query_arguments" {
                        for_each = field_to_match.value == "all_query_arguments" ? [1] : []

                        content {}
                      }

                      dynamic "body" {
                        for_each = field_to_match.value == "body" ? [1] : []

                        content {}
                      }

                      dynamic "method" {
                        for_each = field_to_match.value == "method" ? [1] : []

                        content {}
                      }

                      dynamic "query_string" {
                        for_each = field_to_match.value == "query_string" ? [1] : []

                        content {}
                      }

                      dynamic "single_header" {
                        for_each = field_to_match.value == "single_header" ? [1] : []

                        content {
                          name = single_header.value.name
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = field_to_match.value == "single_query_argument" ? [1] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }

                      dynamic "uri_path" {
                        for_each = field_to_match.value == "uri_path" ? [1] : []

                        content {}
                      }
                    }
                  }

                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }
          }
        }

        dynamic "or_statement" {
          for_each = rule.value.and_or == "or" ? [1] : []

          content {
            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "size_constraint_statement"])

              content {
                size_constraint_statement {
                  comparison_operator = statement.value.comparison_operator
                  size                = statement.value.size

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "query_string" {
                        for_each = field_to_match.key == "query_string" ? [1] : []
                        content {}
                      }
                    }
                  }
                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }

            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "byte_match_statements"])

              content {
                byte_match_statement {
                  positional_constraint = statement.value.positional_constraint
                  search_string         = statement.value.search_string

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "all_query_arguments" {
                        for_each = field_to_match.value == "all_query_arguments" ? [1] : []

                        content {}
                      }

                      dynamic "body" {
                        for_each = field_to_match.value == "body" ? [1] : []

                        content {}
                      }

                      dynamic "method" {
                        for_each = field_to_match.value == "method" ? [1] : []

                        content {}
                      }

                      dynamic "query_string" {
                        for_each = field_to_match.value == "query_string" ? [1] : []

                        content {}
                      }

                      dynamic "single_header" {
                        for_each = field_to_match.value == "single_header" ? [1] : []

                        content {
                          name = single_header.value.name
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = field_to_match.value == "single_query_argument" ? [1] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }

                      dynamic "uri_path" {
                        for_each = field_to_match.value == "uri_path" ? [1] : []

                        content {}
                      }
                    }
                  }

                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }

            dynamic "statement" {
              for_each = { for k, v in rule.value.statements : k => v if k == "geo_match_statement" }

              content {
                geo_match_statement {
                  country_codes = statement.value.country_codes
                }
              }
            }

            dynamic "statement" {
              for_each = { for k, v in rule.value.statements : k => v if k == "ip_set_reference_statement" }

              content {
                ip_set_reference_statement {
                  arn = lookup(statement.value, "arn", aws_wafv2_ip_set.this[statement.value.ip_set_key].arn)
                }
              }
            }

            dynamic "statement" {
              for_each = flatten([for k, v in rule.value.statements : v if k == "regex_pattern_set_reference_statements"])

              content {
                regex_pattern_set_reference_statement {

                  arn = lookup(statement.value, "arn", aws_wafv2_regex_pattern_set.this[statement.value.regex_set_key].arn)

                  dynamic "field_to_match" {
                    for_each = statement.value.field_to_match != null ? statement.value.field_to_match : {}

                    content {
                      dynamic "all_query_arguments" {
                        for_each = field_to_match.value == "all_query_arguments" ? [1] : []

                        content {}
                      }

                      dynamic "body" {
                        for_each = field_to_match.value == "body" ? [1] : []

                        content {}
                      }

                      dynamic "method" {
                        for_each = field_to_match.value == "method" ? [1] : []

                        content {}
                      }

                      dynamic "query_string" {
                        for_each = field_to_match.value == "query_string" ? [1] : []

                        content {}
                      }

                      dynamic "single_header" {
                        for_each = field_to_match.value == "single_header" ? [1] : []

                        content {
                          name = single_header.value.name
                        }
                      }

                      dynamic "single_query_argument" {
                        for_each = field_to_match.value == "single_query_argument" ? [1] : []

                        content {
                          name = single_query_argument.value.name
                        }
                      }

                      dynamic "uri_path" {
                        for_each = field_to_match.value == "uri_path" ? [1] : []

                        content {}
                      }
                    }
                  }

                  text_transformation {
                    priority = lookup(statement.value.text_transformation, "priority", null)
                    type     = lookup(statement.value.text_transformation, "type", "NONE")
                  }
                }
              }
            }
          }
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = lookup(rule.value.visibility_config, "cloudwatch_metrics_enabled", true)
        sampled_requests_enabled   = lookup(rule.value.visibility_config, "sampled_requests_enabled", true)
        metric_name                = rule.value.name
      }
    }
  }
}
