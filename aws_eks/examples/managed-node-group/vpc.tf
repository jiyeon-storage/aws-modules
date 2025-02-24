module "vpc" {
  source  = "../../../aws_vpc"
  prefix  = format("test-%s", random_string.random.result)
  env     = "test"
  team    = "test"
  purpose = "ops"

  cidr_block          = local.vpc_cidr
  azs                 = local.azs
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
      "karpenter.sh/discovery" = format("%s-%s-%s-eks-00", local.tags.env, local.tags.account, local.tags.purpose)
    }
  }
}