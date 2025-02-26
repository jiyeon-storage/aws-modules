module "elasticache" {
  source = ".."

  prefix     = local.prefix
  env        = local.env
  team       = local.team
  purpose    = local.purpose

  replication_group_id        = format("%s-%s-%s", local.prefix, local.env, local.purpose)
  create_cluster              = false
  create_replication_group    = true
  automatic_failover_enabled  = true
  replicas_per_node_group     = 1
  log_delivery_configuration  = {}
  maintenance_window          = "wed:07:00-wed:08:00"
  apply_immediately           = true
  transit_encryption_enabled  = false
  at_rest_encryption_enabled  = false
  
  
  # backup
  #snapshot_retention_limit    = 35
  #snapshot_window             = "02:00-03:00"

  engine_version   = "6.2"
  node_type        = "cache.t4g.small"
  #num_cache_nodes  = 1
  multi_az_enabled = true
  description      = "${local.prefix}-redis-terraform"
  # Security Group
  create_security_group = false
  security_group_ids    = local.security_groups
  #vpc_id = module.vpc.vpc_id
  # security_group_rules = {
  #   ingress_vpc = {
  #     # Default type is `ingress`
  #     # Default port is based on the default engine port
  #     description = "VPC traffic"
  #     cidr_ipv4   = module.vpc.vpc_cidr_block
  #   }
  # }

  # Subnet Group
  create_subnet_group      = false
  subnet_group_name        = local.subnet_group
  # subnet_group_description = format("%s-%s-%s subnet group", local.prefix, local.env, local.purpose)
  # subnet_ids               = module.vpc.private_subnets

  # Parameter Group
  create_parameter_group      = false
  parameter_group_name        = local.parameter_group
  # parameter_group_family      = "redis6"
  # parameter_group_description = format("%s-%s-%s parameter group", local.prefix, local.env, local.purpose)
  # parameters = [
  #   {
  #     name  = "latency-tracking"
  #     value = "yes"
  #   }
  # ]

}