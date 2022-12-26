resource "aws_lb" "alb" {
  name = local.lb_name

  load_balancer_type         = var.load_balancer_type
  internal                   = var.internal
  security_groups            = var.load_balancer_type == "application" ? var.security_group_ids : null
  subnets                    = var.subnet_ids
  idle_timeout               = var.idle_timeout
  enable_deletion_protection = var.enable_deletion_protection

  dynamic "access_logs" {
    for_each = length(var.access_log) != 0 ? [1] : []

    content {
      bucket  = lookup(var.access_log, "bucket", null)
      prefix  = lookup(var.access_log, "prefix", null)
      enabled = lookup(var.access_log, "enabled", null)
    }
  }

  tags = merge(local.default_tags, {
    Name = local.lb_name,
  })
}

resource "aws_lb_listener" "redirect" {
  for_each = lookup(var.listeners, "redirect", {})

  load_balancer_arn = aws_lb.alb.arn

  port            = lookup(each.value, "port", 80)
  protocol        = lookup(each.value, "protocol", "HTTP")
  certificate_arn = lookup(each.value, "protocol") == "HTTPS" ? lookup(each.value, "certificate_arn", null) : null
  ssl_policy      = lookup(each.value, "protocol") == "HTTPS" ? lookup(each.value, "ssl_policy", "ELBSecurityPolicy-2016-08") : null

  default_action {
    type = "redirect"

    redirect {
      port        = lookup(each.value, "redirect_port", 443)
      protocol    = lookup(each.value, "redirect_protocol", "HTTPS")
      status_code = lookup(each.value, "redirect_status_code", "HTTP_301")
    }
  }
}

resource "aws_lb_listener" "forward" {
  for_each = lookup(var.listeners, "forward", {})

  load_balancer_arn = aws_lb.alb.arn

  port            = lookup(each.value, "port", 443)
  protocol        = lookup(each.value, "protocol", "HTTPS")
  certificate_arn = lookup(each.value, "protocol") == "HTTPS" ? lookup(each.value, "certificate_arn", null) : null
  ssl_policy      = lookup(each.value, "protocol") == "HTTPS" ? lookup(each.value, "ssl_policy", "ELBSecurityPolicy-FS-1-2-Res-2020-10") : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this[each.value["target_group_key"]].arn
  }
}

resource "aws_lb_listener_certificate" "forward" {
  for_each = lookup(var.listeners, "extra_certificate_arns", {})

  listener_arn    = each.value["listener_type"] == "forward" ? aws_lb_listener.forward[each.value["listener_key"]].arn : aws_lb_listener.redirect[each.value["listener_key"]]
  certificate_arn = each.value["certificate_arn"]
}

resource "aws_lb_target_group" "this" {
  for_each = var.target_groups

  name = substr(format("%s%s-%s", var.prefix, var.env, each.value.name), 0, 32)

  vpc_id               = var.vpc_id
  port                 = lookup(each.value, "listen_port", 80)
  protocol             = lookup(each.value, "protocol", "HTTP")
  target_type          = lookup(each.value, "target_type", "instance")
  deregistration_delay = lookup(each.value, "deregistration_delay", 10)

  health_check {
    enabled             = lookup(each.value["health_check"], "enabled", true)
    interval            = lookup(each.value["health_check"], "interval", 30)
    path                = var.load_balancer_type != "network" ? lookup(each.value["health_check"], "path", "/") : null
    port                = lookup(each.value["health_check"], "port", null)
    healthy_threshold   = lookup(each.value["health_check"], "healthy_threshold", 3)
    unhealthy_threshold = lookup(each.value["health_check"], "unhealthy_threshold", 2)
    timeout             = var.load_balancer_type != "network" ? lookup(each.value["health_check"], "timeout", 30) : null
    protocol            = lookup(each.value["health_check"], "protocol", "HTTP")
    matcher             = var.load_balancer_type != "network" ? lookup(each.value["health_check"], "matcher", 200) : null

  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_lb_target_group_attachment" "this" {
  for_each = { for k, v in local.instance_attachments : v["key"] => v }

  target_group_arn = aws_lb_target_group.this[each.value.target_group_key].arn
  target_id        = each.value.target_id
  port             = each.value.target_port
}

resource "aws_autoscaling_attachment" "this" {
  for_each = local.asg_attachments

  lb_target_group_arn    = aws_lb_target_group.this[each.key].arn
  autoscaling_group_name = lookup(each.value["targets"], "asg_name", null)
}
