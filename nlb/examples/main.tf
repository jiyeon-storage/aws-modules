module "nlb" {
  source = ".."


  prefix  = local.prefix
  env     = local.env
  team    = local.team
  purpose = local.purpose


  name = format("%s-%s-%s-internal", local.prefix, local.purpose, local.env)

  load_balancer_type               = "network"
  vpc_id                           = local.vpc_id
  subnets                          = [local.private_2a_subnets_id, local.private_2c_subnets_id]
  enable_deletion_protection       = false
  internal                         = true

  ############ Security Group #############
  # enforce_security_group_inbound_rules_on_private_link_traffic = "off"
  # security_group_ingress_rules = {
  #   all_tcp = {
  #     from_port   = 80
  #     to_port     = 84
  #     ip_protocol = "tcp"
  #     description = "TCP traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  #   all_udp = {
  #     from_port   = 80
  #     to_port     = 84
  #     ip_protocol = "udp"
  #     description = "UDP traffic"
  #     cidr_ipv4   = "0.0.0.0/0"
  #   }
  # }
  # security_group_egress_rules = {
  #   all = {
  #     ip_protocol = "-1"
  #     cidr_ipv4   = module.vpc.vpc_cidr_block
  #   }
  # }

  # access_logs = {
  #   bucket = module.log_bucket.s3_bucket_id
  # }

  listeners = {
    nlb_listener = {
      port                     = 8080
      protocol                 = "TCP"
      tcp_idle_timeout_seconds = 60
      forward = {
        target_group_key = "nlb-target"
      }
    }
  }

  target_groups = {
    nlb-target = {
      name                 = format("%s-%s-%s-tg-internal", local.prefix, local.purpose, local.env)
      port                 = 8080
      protocol             = "TCP"
      target_type          = "instance"
      #target_id            = ""
      deregistration_delay = 30
      health_check = {
        enabled             = true
        protocol            = "TCP"
        interval            = 30
        port                = "traffic-port"
        healthy_threshold   = 3
        unhealthy_threshold = 3
        timeout             = 6
      }
    }
  }
}
