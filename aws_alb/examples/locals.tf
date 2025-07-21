locals {
  env        = "dev"
  purpose    = "alb"
  prefix     = "common"
  team       = "devops"

  region = "ap-northeast-2"

  vpc_id               = "vpc-******"
  public_2a_subnets_id = "subnet-******"
  public_2c_subnets_id = "subnet-***********"
  certificate_arn      = "arn:aws:acm:******************************"
}