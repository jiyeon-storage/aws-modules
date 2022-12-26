resource "aws_s3_bucket" "this" {
  bucket = var.bucket_name

  tags = merge(local.default_tags, {
    Name = var.bucket_name
  })
}

resource "aws_s3_bucket_acl" "this" {
  count = var.required_bucket_acl ? 1 : 0

  bucket = aws_s3_bucket.this.id
  acl    = var.bucket_acl
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.this.id

  versioning_configuration {
    status     = lookup(var.versioning, "enabled", "Enabled")
    mfa_delete = lookup(var.versioning, "mfa_delete", null)
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  count = length(keys(var.sse_config)) != 0 ? 1 : 0

  bucket = aws_s3_bucket.this.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = lookup(var.sse_config, "kms_master_key_id", "aws/s3")
      sse_algorithm     = lookup(var.sse_config, "sse_algorithm", "aws:kms")
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "this" {
  count = length(keys(var.ownership_config)) != 0 ? 1 : 0

  bucket = aws_s3_bucket.this.id

  rule {
    object_ownership = lookup(var.ownership_config, "object_ownership", "BucketOwnerPreferred")
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = var.bucket_policy != null ? 1 : 0

  bucket = aws_s3_bucket.this.id
  policy = data.aws_iam_policy_document.this[0].json
}

resource "aws_s3_bucket_public_access_block" "this" {
  count = var.enable_public_access_block ? 1 : 0

  bucket = aws_s3_bucket.this.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.this]
}

resource "aws_iam_policy" "full" {
  count = var.create_full_access_policy ? 1 : 0

  name        = format("%s-s3-full-access-policy", aws_s3_bucket.this.id)
  description = format("%s-s3-full-access-policy", aws_s3_bucket.this.id)
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:aws:s3:::%s", aws_s3_bucket.this.id),
          format("arn:aws:s3:::%s/*", aws_s3_bucket.this.id),
        ]
      },
    ]
  })

  tags = merge(local.default_tags, {
    Name = format("%s-s3-full-access-policy", aws_s3_bucket.this.id)
  })
}

resource "aws_iam_policy" "readonly" {
  count = var.create_readonly_access_policy ? 1 : 0

  name        = format("%s-s3-readonly-access-policy", aws_s3_bucket.this.id)
  description = format("%s-s3-readonly-access-policy", aws_s3_bucket.this.id)
  path        = "/"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject*",
          "s3:ListMultipart*",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:aws:s3:::%s", aws_s3_bucket.this.id),
          format("arn:aws:s3:::%s/*", aws_s3_bucket.this.id),
        ]
      },
      {
        Action = [
          "s3:ListBucket",
        ]
        Effect = "Allow"
        Resource = [
          format("arn:aws:s3:::%s", aws_s3_bucket.this.id),
          format("arn:aws:s3:::%s/*", aws_s3_bucket.this.id),
        ]
      },
    ]
  })

  tags = merge(local.default_tags, {
    Name = format("%s-s3-readonly-access-policy", aws_s3_bucket.this.id)
  })
}

resource "aws_s3_bucket_cors_configuration" "this" {
  bucket = var.bucket_name

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "HEAD"]
    allowed_origins = ["*"]
    expose_headers  = []
    max_age_seconds = 3000
  }
}
