resource "aws_lb" "alb" {
  name = var.name

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
    Name = var.name,
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

  name = substr(format("%s", each.value.name), 0, 32)

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

resource "aws_lb_listener_rule" "forward" {
  for_each = { for v in local.listener_rules : "${v.listener_key}/${v.rule_key}" => v }

  listener_arn = try(each.value.listener_arn, aws_lb_listener.forward[each.value.listener_key].arn)
  priority     = try(each.value.priority, null)

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "authenticate-cognito"]

    content {
      type  = "authenticate-cognito"
      order = try(action.value.order, null)

      authenticate_cognito {
        authentication_request_extra_params = try(action.value.authentication_request_extra_params, null)
        on_unauthenticated_request          = try(action.value.on_unauthenticated_request, null)
        scope                               = try(action.value.scope, null)
        session_cookie_name                 = try(action.value.session_cookie_name, null)
        session_timeout                     = try(action.value.session_timeout, null)
        user_pool_arn                       = action.value.user_pool_arn
        user_pool_client_id                 = action.value.user_pool_client_id
        user_pool_domain                    = action.value.user_pool_domain
      }
    }
  }

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "authenticate-oidc"]

    content {
      type  = "authenticate-oidc"
      order = try(action.value.order, null)

      authenticate_oidc {
        authentication_request_extra_params = try(action.value.authentication_request_extra_params, null)
        authorization_endpoint              = action.value.authorization_endpoint
        client_id                           = action.value.client_id
        client_secret                       = action.value.client_secret
        issuer                              = action.value.issuer
        on_unauthenticated_request          = try(action.value.on_unauthenticated_request, null)
        scope                               = try(action.value.scope, null)
        session_cookie_name                 = try(action.value.session_cookie_name, null)
        session_timeout                     = try(action.value.session_timeout, null)
        token_endpoint                      = action.value.token_endpoint
        user_info_endpoint                  = action.value.user_info_endpoint
      }
    }
  }

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "redirect"]

    content {
      type  = "redirect"
      order = try(action.value.order, null)

      redirect {
        host        = try(action.value.host, null)
        path        = try(action.value.path, null)
        port        = try(action.value.port, null)
        protocol    = try(action.value.protocol, null)
        query       = try(action.value.query, null)
        status_code = action.value.status_code
      }
    }
  }

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "fixed-response"]

    content {
      type  = "fixed-response"
      order = try(action.value.order, null)

      fixed_response {
        content_type = action.value.content_type
        message_body = try(action.value.message_body, null)
        status_code  = try(action.value.status_code, null)
      }
    }
  }

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "forward"]

    content {
      type             = "forward"
      order            = try(action.value.order, null)
      target_group_arn = try(action.value.target_group_arn, aws_lb_target_group.this[action.value.target_group_key].arn, null)
    }
  }

  dynamic "action" {
    for_each = [for action in each.value.actions : action if action.type == "weighted-forward"]

    content {
      type  = "forward"
      order = try(action.value.order, null)

      forward {
        dynamic "target_group" {
          for_each = try(action.value.target_groups, [])

          content {
            arn    = try(target_group.value.arn, aws_lb_target_group.this[target_group.value.target_group_key].arn)
            weight = try(target_group.value.weight, null)
          }
        }

        dynamic "stickiness" {
          for_each = try([action.value.stickiness], [])

          content {
            enabled  = try(stickiness.value.enabled, null)
            duration = try(stickiness.value.duration, 60)
          }
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "host_header")]

    content {
      dynamic "host_header" {
        for_each = try([condition.value.host_header], [])

        content {
          values = host_header.value.values
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "http_header")]

    content {
      dynamic "http_header" {
        for_each = try([condition.value.http_header], [])

        content {
          http_header_name = http_header.value.http_header_name
          values           = http_header.value.values
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "http_request_method")]

    content {
      dynamic "http_request_method" {
        for_each = try([condition.value.http_request_method], [])

        content {
          values = http_request_method.value.values
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "path_pattern")]

    content {
      dynamic "path_pattern" {
        for_each = try([condition.value.path_pattern], [])

        content {
          values = path_pattern.value.values
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "query_string")]

    content {
      dynamic "query_string" {
        for_each = try(flatten([condition.value.query_string]), [])

        content {
          key   = try(query_string.value.key, null)
          value = query_string.value.value
        }
      }
    }
  }

  dynamic "condition" {
    for_each = [for condition in each.value.conditions : condition if contains(keys(condition), "source_ip")]

    content {
      dynamic "source_ip" {
        for_each = try([condition.value.source_ip], [])

        content {
          values = source_ip.value.values
        }
      }
    }
  }
}