variable "env" {
  type        = string
  description = "Environment"
}

variable "purpose" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "prefix" {
  type        = string
  description = "The prefix name used in this module"
}

variable "alb_arn" {
  type        = string
  description = "ALB arn info to be linked to webacl"
  default     = null
}

variable "ip_set_v1_config" {
  type        = any
  description = "v1 ip set configuration"
  default     = []
}

variable "ip_set_v2_config" {
  type        = any
  description = "v2 ip set configuration"
  default     = []
}

variable "regex_pattern_set_config" {
  type        = any
  description = "regex pattern set configuration"
  default     = []
}
variable "rule_group_v1_config" {
  type        = any
  description = "v1 rule group configuration"
  default     = {}
}

variable "rule_group_v2_config" {
  type        = any
  description = "v2 rule group configuration"
  default     = {}
}

variable "web_acl_config" {
  type        = any
  description = "webacl configuration"
  default     = {}
}

variable "visibility_config" {
  type        = any
  description = "cloudwatch_matreics_flag/sampled_requests_flag"
  default = {
    cloudwatch_metrics_enabled = true,
    sampled_requests_enabled   = true
  }
}

variable "log_s3" {
  type        = string
  description = "webacl access log"
  default     = ""
}

variable "enabled_logging_method" {
  type        = bool
  description = "webacl access logging method check"
  default     = false
}

variable "enabled_logging_query" {
  type        = bool
  description = "webacl access logging query check"
  default     = false
}

variable "enabled_logging_uri_path" {
  type        = bool
  description = "webacl access logging uri_path check"
  default     = false
}

variable "logging_retention_in_days" {
  type        = number
  description = "webacl access logging retention time"
  default     = 0 # infinity
}

