locals {
  name   = "ex-eks-mng"
  region = "ap-northeast-2"

  vpc_cidr = "10.0.0.0/16"
  azs      = ["ap-northeast-2a", "ap-northeast-2c"]
  
  tags = {
    env        = "DEV"
    team       = "DevOps"
    purpose    = "test"
    managed_by = "terraform"
  }
}
