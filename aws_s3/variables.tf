variable "env" {
  type        = string
  description = "Environment like prod, stg, dev, alpha"
}

variable "team" {
  type        = string
  description = "The team tag used to managed resources."
}

variable "purpose" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "bucket_name" {
  type        = string
  description = "The bucket name"
}

variable "bucket_acl" {
  type        = string
  description = "The canned ACL to apply to the bucket"
  default     = "private"
}

variable "versioning" {
  description = "Map containing versioning configuration."
  type        = map(string)
  default = {
    enabled    = "Enabled"
    mfa_delete = null
  }
}

variable "sse_config" {
  description = "Map containing server-side encryption configuration."
  type        = any
  default     = {}
}

variable "ownership_config" {
  description = "Map containing bucket ownership configuration."
  type        = any
  default     = {}
}

variable "bucket_policy" {
  type        = string
  description = "bucket policy"
  default     = null
}

variable "enable_public_access_block" {
  type        = bool
  description = "whether or not to enable public access block"
  default     = true
}

variable "create_full_access_policy" {
  type        = bool
  description = "whether or not to create iam policy of s3 full access"
  default     = true
}

variable "create_readonly_access_policy" {
  type        = bool
  description = "whether or not to create iam policy of s3 readonly access"
  default     = true
}

variable "required_bucket_acl" {
  type        = bool
  description = "wheter or not to set acl"
  default     = false
}
