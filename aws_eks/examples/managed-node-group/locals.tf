locals {
  name   = "ex-eks-mng"
  region = "eu-west-1"

  vpc_cidr = "10.0.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  tags = {
    env        = "DEV"
    team       = "DevOps"
    purpose    = "test"
    managed_by = "terraform"
  }
}
