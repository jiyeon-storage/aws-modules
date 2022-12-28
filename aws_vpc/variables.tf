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

variable "cidr_block" {
  type        = string
  description = "The CIDR block of VPC"
}

variable "subnet_cidrs" {
  type        = any
  description = "The subnet cidrs (public/private/database)"
}

variable "subnet_tags" {
  type        = any
  description = "The subnet tag used to managed resources (public/private/databse)"
}

variable "vpc_options" {
  type        = any
  description = "VPC options like enable_dns_hostnames, enable_dns_support"
  default     = {}
}

variable "azs" {
  type        = list(string)
  description = "AWS availability zones in subnets"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Enable the single NAT gateway or not. If this variable is disabled, NAT gateways are created cross all AZs"
  default     = true
}

variable "enable_nat_private" {
  type        = bool
  description = "Flag to enable or disable nat gateway in private subnet"
  default     = true
}

variable "enable_nat_database" {
  type        = bool
  description = "Flag to enable or disable nat gateway in database subnet"
  default     = true
}

variable "public_routes" {
  type        = list(map(string))
  description = "Routing rules for public subnets (not used)"
  default     = []
}

variable "private_routes" {
  type        = list(map(string))
  description = "Routing rules for private subnets"
  default     = []
}

variable "database_routes" {
  type        = list(map(string))
  description = "Routing rules for database subnets"
  default     = []
}
