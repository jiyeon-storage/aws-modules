terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}

provider "random" {}

resource "random_string" "random" {
  length           = 10
  special          = true
  override_special = "/!@£$"
}

module "redis" {
  source = "../"

  # tag
  env     = "test"
  team    = "test"
  purpose = "testDB"
  prefix  = "test"

  vpc_id     = aws_vpc.this.id
  subnet_ids = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]

  redis_family = "redis5.0"
  redis_parameters = [
    {
      name  = "notify-keyspace-events"
      value = "Ex"
    }
  ]

  # redis config
  redis_config = {
    node_type                  = "cache.r5.large"
    port                       = 6379
    allowed_security_groups    = [aws_security_group.this.id]
    allowed_cidrs              = ["10.0.10.0/24", "10.0.20.0/24"]
    num_cache_clusters         = 2
    apply_immediately          = true
    automatic_failover_enabled = true
    engine_version             = "5.x"
    at_rest_encryption_enabled = false
    multi_az_enabled           = true
    maintenance_window         = "Mon:22:00-Mon:23:00"
    snapshot_retention_limit   = 7
    snapshot_window            = "05:00-07:00"
    auto_minor_version_upgrade = false
  }
}
