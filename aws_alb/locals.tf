locals {
  default_tags = {
    env        = var.env
    team       = var.team
    purpose    = var.purpose
    managed_by = "terraform"
  }

  lb_name = var.fixed_name != "" ? var.fixed_name : format("%s%s-%s-alb", var.prefix, var.env, var.purpose)

  instance_attachments = distinct(flatten(
    [
      for k1, v1 in var.target_groups : [
        for k2, v2 in v1.targets : {
          key              = format("%s-%s", k1, k2)
          target_group_key = k1,
          target_id        = v2.target_id,
          target_port      = v2.target_port
        }
      ] if v1["attachment_type"] == "instance"
  ]))

  asg_attachments = { for k, v in var.target_groups : k => v if v["attachment_type"] == "asg" }
}

