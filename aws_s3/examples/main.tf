provider "aws" {
  region = "ap-northeast-2"
}

module "s3" {
  source = "../"

  env         = "test"
  team        = "test"
  purpose     = "test"
  bucket_name = "test-testtttt"
  versioning = {
    enabled = "Enabled"
  }
  ownership_config = {
    object_ownership = "BucketOwnerPreferred"
  }
  required_bucket_acl           = false
  create_readonly_access_policy = true
  create_full_access_policy     = false
}
