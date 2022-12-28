provider "aws" {
  region = "ap-northeast-2"
}

resource "random_string" "random" {
  length  = 4
  special = false
}

locals {
  prefix  = "test"
  env     = "test"
  team    = "test"
  purpose = "ops"
}

module "vpc" {
  source = "../"

  prefix  = format("test-%s", random_string.random.result)
  env     = "test"
  team    = "test"
  purpose = "ops"

  cidr_block          = "10.234.0.0/16"
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  single_nat_gateway  = false
  enable_nat_private  = true
  enable_nat_database = false

  subnet_cidrs = {
    public   = ["10.234.0.0/24", "10.234.1.0/24"]
    private  = ["10.234.2.0/24", "10.234.3.0/24"]
    database = ["10.234.4.0/24", "10.234.5.0/24"]
  }

  subnet_tags = {
    public = {
      "kubernetes.io/role/elb" = "1"
    }
    private = {
      "kubernetes.io/role/internal-elb" = "1"
    }
  }
}

