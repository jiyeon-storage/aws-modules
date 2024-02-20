output "instance_id" {
  value = aws_instance.this.id
}

output "iam_role_arn" {
  value = var.required_iam_role ? aws_iam_role.this[0].arn : null
}

output "iam_role_name" {
  value = var.required_iam_role ? aws_iam_role.this[0].name : null
}

output "private_ip" {
  value = aws_instance.this.private_ip
}
