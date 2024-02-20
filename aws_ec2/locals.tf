data "aws_vpc" "selected" {
  id = var.vpc_id
}

locals {
  default_tags = {
    env        = var.env
    team       = var.team
    purpose    = var.purpose
    managed_by = "terraform"
  }
}
