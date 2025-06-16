locals {
  env        = var.env
  team       = var.team
  purpose    = var.purpose
  
  create_origin_access_identity = var.create_origin_access_identity && length(keys(var.origin_access_identities)) > 0
  create_origin_access_control  = var.create_origin_access_control && length(keys(var.origin_access_control)) > 0
  create_vpc_origin             = var.create_vpc_origin && length(keys(var.vpc_origin)) > 0
}