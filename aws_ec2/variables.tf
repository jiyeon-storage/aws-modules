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
  type        = string
  description = "The instance name"
}

variable "vpc_id" {
  type        = string
  description = "The VPC id for EC2 instance"
}

variable "subnet_id" {
  type        = string
  description = "The subnet id for EC2 instance"
}

variable "ami_id" {
  type        = string
  description = "The AMI id for EC2 instance"
}

variable "instance_type" {
  type        = string
  description = "The instance type for EC2 instance"
  default     = "t3.medium"
}

variable "associate_public_ip_address" {
  description = "Whether to associate a public IP address with an instance in a VPC"
  type        = bool
  default     = false
}

variable "ebs_optimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  type        = bool
  default     = true
}

variable "key_name" {
  type        = string
  description = "The key name for EC2 instance"
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs."
  type        = bool
  default     = true
}

variable "vpc_security_group_ids" {
  type        = list(string)
  description = "The security group ids for EC2 instance"
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead."
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption."
  type        = string
  default     = null
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type        = list(any)
  default     = []
}

variable "ebs_block_device" {
  description = "Additional EBS block devices to attach to the instance"
  type        = list(map(string))
  default     = []
}

variable "metadata_options" {
  description = "Customize the metadata options of the instance"
  type        = map(string)
  default = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = "2"
    instance_metadata_tags      = null
  }
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "required_iam_role" {
  type        = bool
  description = "Whether IAM role is required"
  default     = false
}

variable "required_eip" {
  type        = bool
  description = "Whether EIP is required"
  default     = false
}

variable "attached_policy_arn" {
  type        = list(string)
  description = "attachecd policy to role"
  default     = null
}

variable "role_name" {
  type        = string
  description = "After creating ec2, write role that exists name"
  default     = null
}
