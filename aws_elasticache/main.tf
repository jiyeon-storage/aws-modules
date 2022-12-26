resource "aws_elasticache_subnet_group" "this" {
  name = lower(format("%s%s-%s", var.prefix, var.env, var.purpose))

  description = "Elasticache subnet group"
  subnet_ids  = var.subnet_ids

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-sub", var.prefix, var.env, var.purpose)
  })
}

resource "aws_elasticache_parameter_group" "pg" {
  name = lower(format("%s%s-%s", var.prefix, var.env, var.purpose))

  description = "Elasticache parameter group"
  family      = var.redis_family

  dynamic "parameter" {
    for_each = { for k, v in var.redis_parameters : k => v }
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-sub", var.prefix, var.env, var.purpose)
  })
}

resource "aws_elasticache_replication_group" "this" {
  replication_group_id = format("%s%s-%s-redis", var.prefix, var.env, var.purpose)

  description                = format("%s%s-%s-redis", var.prefix, var.env, var.purpose)
  node_type                  = lookup(var.redis_config, "node_type", null)
  port                       = lookup(var.redis_config, "port", 6379)
  multi_az_enabled           = lookup(var.redis_config, "multi_az_enabled", true)
  num_cache_clusters         = lookup(var.redis_config, "num_cache_clusters", 2)
  parameter_group_name       = join("", aws_elasticache_parameter_group.pg.*.name)
  automatic_failover_enabled = lookup(var.redis_config, "automatic_failover_enabled", true)
  auto_minor_version_upgrade = lookup(var.redis_config, "auto_minor_version_upgrade", false)
  subnet_group_name          = aws_elasticache_subnet_group.this.name
  security_group_ids = distinct(concat(
    [aws_security_group.this.id],
    lookup(var.redis_config, "allowed_security_groups", [])),
  )
  maintenance_window         = lookup(var.redis_config, "maintenance_window", null)
  notification_topic_arn     = lookup(var.redis_config, "notification_topic_arn", null)
  engine_version             = lookup(var.redis_config, "engine_version", null)
  at_rest_encryption_enabled = lookup(var.redis_config, "at_rest_encryption_enabled", false)
  kms_key_id                 = lookup(var.redis_config, "kms_key_id", null)
  snapshot_name              = lookup(var.redis_config, "snapshot_name", null)
  snapshot_arns              = lookup(var.redis_config, "snapshot_arns", null)
  snapshot_window            = lookup(var.redis_config, "snapshot_window", null)
  snapshot_retention_limit   = lookup(var.redis_config, "snapshot_retention_limit", null)
  final_snapshot_identifier  = format("%s%s-%s-redis-%s-finalsnapshot", var.prefix, var.env, var.purpose, formatdate("YYYY-MM-DD-hhmmss", timestamp()))
  apply_immediately          = lookup(var.redis_config, "apply_immediately", false)

  tags = merge(local.default_tags, {
    Name = format("%s%s-%s-sub", var.prefix, var.env, var.purpose)
  })
}

resource "aws_security_group" "this" {
  name   = format("%s%s-%s-sg", var.prefix, var.env, var.purpose)
  vpc_id = var.vpc_id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = lookup(var.redis_config, "port", 6379)
    to_port     = lookup(var.redis_config, "port", 6379)
    description = "allow elasticcache port from self"
  }

  dynamic "ingress" {
    for_each = lookup(var.redis_config, "allowed_cidrs", null) != null ? [1] : []

    content {
      protocol    = "tcp"
      cidr_blocks = lookup(var.redis_config, "allowed_cidrs", null)
      from_port   = lookup(var.redis_config, "port", 6379)
      to_port     = lookup(var.redis_config, "port", 6379)
      description = "allow elasticcache port from cidr"
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  tags = merge(local.default_tags, {
    Name = format("%s%s-%s", var.prefix, var.env, var.purpose)
  })
}
