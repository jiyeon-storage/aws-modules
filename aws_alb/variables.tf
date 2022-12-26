variable "fixed_name" {
  type        = string
  description = "Fixed name of load balancer. Prefix will be ignored."
  default     = ""
}

variable "prefix" {
  type        = string
  description = "The prefix name used in this module"
}

variable "env" {
  type        = string
  description = "Environment like prod, stg, dev, alpha"
}

variable "team" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "purpose" {
  type        = string
  description = "The team tag used to managed resources"
}

variable "load_balancer_type" {
  type        = string
  default     = "application"
  description = "lb type (application)"
}

variable "internal" {
  type        = bool
  default     = false
  description = "internal lb flag"
}

variable "vpc_id" {
  type        = string
  description = "vpc id info"
}

variable "subnet_ids" {
  type        = list(string)
  description = "lb subnet ids"
}

variable "security_group_ids" {
  type        = list(string)
  description = "lb security group ids"
}

variable "idle_timeout" {
  type        = number
  default     = 60
  description = "lb timeout setting"
}

variable "enable_deletion_protection" {
  type        = bool
  description = "lb delete protect"
}

variable "listeners" {
  type        = any
  default     = {}
  description = "lb listners info (port / protocols)"
}

variable "target_groups" {
  type        = any
  default     = {}
  description = "lb target groups (ec2)"
}

variable "access_log" {
  type        = map(string)
  default     = {}
  description = "lb access log s3 info"
}
