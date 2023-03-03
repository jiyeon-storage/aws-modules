resource "aws_cloudwatch_log_group" "this" {
  name = format("aws-waf-logs-%s%s-%s", var.prefix, var.env, var.purpose)

  retention_in_days = var.logging_retention_in_days

  tags = merge(local.default_tags, {
    Name = format("aws-waf-logs-%s%s-%s", var.prefix, var.env, var.purpose)
  })
}
