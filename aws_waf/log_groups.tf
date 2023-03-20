resource "aws_cloudwatch_log_group" "this" {
  name = format("%s-%s%s-aws-waf-logs", var.env, var.prefix, var.purpose)

  retention_in_days = var.logging_retention_in_days

  tags = merge(local.default_tags, {
    Name = format("%s-%s%s-aws-waf-logs", var.env, var.prefix, var.purpose)
  })
}
