module "vpc" {
  source  = "../../../aws_vpc"
  prefix  = format("test-%s", random_string.random.result)
  env     = local.tags.env
  team    = local.tags.team
  purpose = local.tags.purpose

  cidr_block          = local.vpc_cidr
  azs                 = ["ap-northeast-2a", "ap-northeast-2c"]
  single_nat_gateway  = true
  enable_nat_private  = true

  subnet_cidrs = {
    public   = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 4, k)]
    private  = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 48)]
    intra    = [for k, v in local.azs : cidrsubnet(local.vpc_cidr, 8, k + 52)]
  }

  subnet_tags = {
    public = {
      "kubernetes.io/role/elb" = "1"
    }
    private = {
      "kubernetes.io/role/internal-elb" = "1"
      "karpenter.sh/discovery" = format("%s-%s", local.tag.prefix, var.tag.env)
    }
  }
}