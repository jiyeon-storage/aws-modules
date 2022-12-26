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

variable "prefix" {
  type = string
}

variable "vpc_id" {
  type        = string
  description = "VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "ElastiCache subnet ids"
}

variable "redis_parameters" {
  type        = any
  description = "Redis parameter groups information"
  default     = {}
}

variable "redis_family" {
  type    = string
  default = "redis6.0"
}

variable "redis_config" {
  type        = any
  description = "Redis Cluster Configuration Information"
}
