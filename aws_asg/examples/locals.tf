locals {
  env        = "test"
  team       = "devops"
  purpose    = "asg"
  prefix     = "test"

  region = "ap-northeast-2"

  vpc_id                   = "vpc-000000000000000"
  private_2a_subnets_id    = "subnet-1111111111111111"
  private_2c_subnets_id    = "subnet-2222222222222222"

  asg_iam_role_arn         = "arn:aws:iam::0101010101010:role/AWSServiceRoleForAutoScaling"
  ec2_instance_profile_arn = "arn:aws:iam::0101010101010:instance-profile/ec2-profile"
  ### backend.tf ###
  alb_internal_tg_arn      = data.terraform_remote_state.alb_internal.outputs.target_group["alb-target"].arn
  alb_pubilc_tg_arn        = data.terraform_remote_state.alb_public.outputs.target_group["alb-target"].arn
  security_group_id        = ["sg-111111111111111","sg-222222222222222"] 
  keypair_name             = "test-ec2-key"


  user_data = <<-EOT
    #!/bin/bash
    sudo systemctl restart nginx
  EOT
  
}