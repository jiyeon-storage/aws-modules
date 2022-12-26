output "bucket_name" {
  value = aws_s3_bucket.this.id
}

output "bucket_arn" {
  value = aws_s3_bucket.this.arn
}

output "full_access_policy_arn" {
  value = try(aws_iam_policy.full[0].arn, null)
}

output "readonly_access_policy_arn" {
  value = try(aws_iam_policy.readonly[0].arn, null)
}
