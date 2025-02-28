data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["0101010101010"]

  filter {
    name = "name"

    values = [
      "amzn2-ami",
    ]
  }
}

################################################################################
# Auto Scaling
################################################################################

module "complete" {
  source = ".."

  prefix     = local.prefix
  env        = local.env
  team       = local.team
  purpose    = local.purpose

  # Autoscaling group
  name            = format("%s-%s-%s", local.prefix, local.purpose, local.env)
  use_name_prefix = false
  instance_name   = format("%s-%s-%s", local.prefix, local.purpose, local.env)

  ignore_desired_capacity_changes = true

  min_size                  = 2
  max_size                  = 6
  desired_capacity          = 2
  wait_for_capacity_timeout = 0
  termination_policies      = ["OldestInstance"]
  health_check_grace_period = 30
  health_check_type         = "EC2"
  vpc_zone_identifier       = [local.private_2a_subnets_id, local.private_2c_subnets_id]
  service_linked_role_arn   = local.asg_iam_role_arn

  # Traffic source attachment
  traffic_source_attachments = {
    nlb_internal = {
      traffic_source_identifier = local.nlb_internal_tg_arn
      traffic_source_type       = "elbv2" # default
    },
    nlb_public = {
      traffic_source_identifier = local.nlb_pubilc_tg_arn
      traffic_source_type       = "elbv2" # default
    }

  }

  # Launch template
  launch_template_name        = format("%s-%s-%s-launch", local.prefix, local.purpose, local.env )
  launch_template_description = "${local.label} launch template example"
  update_default_version      = true
  iam_instance_profile_arn    =  local.ec2_instance_profile_arn
  enable_monitoring = false
  image_id          = data.aws_ami.amazon_linux.id
  instance_type     = "t3.micro"
  user_data         = base64encode(local.user_data)
  key_name          = local.keypair_name

  private_dns_name_options = {
    hostname_type     = "ip-name"
    enable_resource_name_dns_a_record = true
  }

  create_iam_instance_profile = false
  security_groups          = local.security_group_id
  metadata_options = {
    http_protocol_ipv6          = "disabled"
  }

  network_interfaces = [
    {
      associate_public_ip_address = false
      security_groups       = local.security_group_id
    }
  ]

  tag_specifications = [
    {
      resource_type = "instance"
      tags          = { TerraformManaged = "true" }
    },
    {
      resource_type = "instance"
      tags          = { Name = format("%s-%s-%s", local.prefix, local.purpose, local.env) }
    }
  ]
  scaling_policies = {
    Autoscaling-Increase = {
      name                      = format("%s-%s-Autoscaling-Increase", local.prefix, local.purpose )
      adjustment_type           = "ChangeInCapacity"
      policy_type               = "SimpleScaling"
      cooldown                  = 300
      scaling_adjustment          = 2
    }
  }
}

# ################################################################################
# # aws_cloudwatch_metric_alarm
# ################################################################################

resource "aws_cloudwatch_metric_alarm" "cpu_utilization_warning" {
  alarm_name          = format("%s-%s-%s-AutoScalingGroup-CPUUtilization-Warning", local.prefix, local.purpose, local.env )
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 40

  dimensions = {
    AutoScalingGroupName = format("%s-%s-%s", local.prefix, local.purpose, local.env)
  }

  alarm_description = "Triggered when CPUUtilization >= 40 for 2 consecutive periods of 300 seconds"
  actions_enabled   = true

  alarm_actions = [module.complete.autoscaling_policy_arns["Autoscaling-Increase"]]

}