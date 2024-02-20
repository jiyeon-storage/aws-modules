resource "aws_iam_role" "this" {
  count = var.required_iam_role ? 1 : 0

  name = format("%s%s-%s-role", var.prefix, var.env, var.purpose)

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy_attachment" "this" {
  for_each = var.required_iam_role == true ? { for k, v in var.attached_policy_arn : k => v } : {}

  name = var.role_name

  roles      = [var.role_name]
  policy_arn = each.value
}
