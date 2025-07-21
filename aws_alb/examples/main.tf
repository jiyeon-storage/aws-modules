resource "random_string" "random" {
  length           = 4
  special          = true
  override_special = "/@£$"
}

resource "aws_security_group" "lb_sg" {
  name   = format("%s-%s-%s-sg", local.env, local.purpose, local.prefix)
  vpc_id = local.vpc_id

  ingress {
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    description = "allow port http,ws from private_subnets"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol    = "tcp"
    from_port   = 443
    to_port     = 443
    description = "allow port http,ws from private_subnets"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = format("%s-%s-%s-sg", local.env, local.purpose, local.prefix)
  }
}

module "alb" {
  source = "../"

  prefix  = local.prefix
  env     = local.env
  purpose = local.purpose
  team    = local.team

  name = format("%s-%s-%s", local.env, local.purpose, local.prefix)
  # vpc
  vpc_id = aws_vpc.this.id

  # access_log
  access_log = {
    bucket  = "test-s3-name",
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
      https_443 = {
      port             = 443
      protocol         = "HTTPS"
      target_group_key = "test_2"
      certificate_arn  = local.certificate_arn

      rules = {
        forward-alpha-test = {
          priority = 1
          actions = [{ type = "forward", target_group_key = "test_2" }]
          conditions = [{ host_header = { values = ["alpha.jiyeon.com"] } }]
        }

        forward-beta-test = {
          priority = 2
          actions = [{ type = "forward", target_group_key = "test_2" }]
          conditions = [{ host_header = { values = ["beta.jiyeon.com"] } }]
        }
      }
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
    },
    test_2 = {
      name                 = "test_alb"
      target_type          = "instance"
      attachment_type      = "instance"
      protocol             = "HTTP"
      listen_port          = 80
      deregistration_delay = 10
      health_check = {
        enabled             = true
        interval            = 15
        path                = "/"
        port                = 80
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 10
        protocol            = "HTTP"
        matcher             = "200"
      }
      targets = [
      ]
    }
  }
}
