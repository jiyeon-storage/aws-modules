output "ip_sets_id" {
  value = { for k, v in aws_wafv2_ip_set.this : k => v.id }
}

output "ip_sets_arn" {
  value = { for k, v in aws_wafv2_ip_set.this : k => v.arn }
}

output "regex_pattern_set_id" {
  value = { for k, v in aws_wafv2_regex_pattern_set.this : k => v.id }
}

output "regex_pattern_set_arn" {
  value = { for k, v in aws_wafv2_regex_pattern_set.this : k => v.arn }
}

output "rule_groups_id" {
  value = { for k, v in aws_wafv2_rule_group.this : k => v.id }
}

output "rule_groups_arn" {
  value = { for k, v in aws_wafv2_rule_group.this : k => v.arn }
}

output "web_acl_id" {
  value = aws_wafv2_web_acl.this.id
}

output "web_acl_arn" {
  value = aws_wafv2_web_acl.this.arn
}

output "web_acl_capacity" {
  value = aws_wafv2_web_acl.this.capacity
}

output "log_group_arn" {
  value = aws_cloudwatch_log_group.this.arn
}
