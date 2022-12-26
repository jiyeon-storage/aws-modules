output "lb_arn" {
  value = aws_lb.alb.arn
}

output "lb_listener_redirect_arn" {
  value = { for k, v in aws_lb_listener.redirect :
    k => {
      arn = v.arn
    }
  }
}

output "lb_listener_forward_arn" {
  value = { for k, v in aws_lb_listener.forward :
    k => {
      arn = v.arn
    }
  }
}

output "lb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "lb_zone_id" {
  value = aws_lb.alb.zone_id
}
