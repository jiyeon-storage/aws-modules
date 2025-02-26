locals {
  env        = "test"
  team       = "devops"
  purpose    = "redis"
  prefix     = "test"

  region = "ap-northeast-2"

  vpc_id               = "vpc-000000000000000"
  security_groups       = ["sg-1111111111111111","sg-2222222222222222"]
  subnet_group          = "test-sn-redis"
  parameter_group       = "test-pg-6-redis"
  
}