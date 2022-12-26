resource "random_string" "random" {
  length           = 4
  special          = true
  override_special = "/@£$"
}

module "alb" {
  source = "../"

  # tag
  env     = "test"
  prefix  = "ct"
  team    = "ops"
  purpose = "msigner"

  # vpc
  vpc_id = aws_vpc.this.id

  # access_log
  access_log = {
    bucket  = "test-s3-mysql-update-user",
    preix   = "access_logs",
    enabled = true
  }

  # lb
  load_balancer_type         = "application"
  internal                   = false
  subnet_ids                 = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  security_group_ids         = [aws_security_group.this.id]
  idle_timeout               = 30
  enable_deletion_protection = false

  # lb-listener
  listeners = {
    forward = {
      http_8080 = {
        port             = 8080
        protocol         = "HTTP"
        target_group_key = "test"
      }
      http_12701 = {
        port             = 12701
        protocol         = "HTTP"
        target_group_key = "test"
      }
    }
  }

  # tg
  target_groups = {
    "test" = {
      name                 = "test"
      target_type          = "instance"
      attachment_type      = "instance"
      protocol             = "HTTP"
      listen_port          = 80
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 30
        path                = "/"
        port                = 80
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200-399"
      },
      targets = [
        {
          target_id   = aws_instance.instance1.id
          target_port = 80
        },
        {
          target_id   = aws_instance.instance2.id
          target_port = 80
        },
      ]
    }
  }
}
