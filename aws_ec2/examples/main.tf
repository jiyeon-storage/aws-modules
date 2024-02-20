provider "aws" {
  region = "ap-northeast-2"
}

resource "random_string" "random" {
  length  = 10
  special = false
}

resource "aws_key_pair" "this" {
  key_name   = "test-key"
  public_key = "ssh-rsa AAAA"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-20211129"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = [""]
}

resource "aws_security_group" "this" {
  name   = format("ec2-test-%s-sg", random_string.random.result)
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    from_port   = 8080
    to_port     = 8080
    description = "allow e port from self"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

module "ec2" {
  source = "../"

  prefix  = "test"
  env     = "test"
  team    = "test"
  purpose = "test"

  vpc_id                      = aws_vpc.this.id
  subnet_id                   = aws_subnet.subnet1.id
  ami_id                      = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  ebs_optimized               = true
  key_name                    = aws_key_pair.this.key_name
  source_dest_check           = true
  vpc_security_group_ids      = [aws_security_group.this.id]
  root_block_device = [
    {
      volume_size = 50
      volume_type = "gp3"
    }
  ]
  required_iam_role   = true
  required_eip        = false
  attached_policy_arn = ["arn:aws:iam::"]
  role_name           = "test-role"
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "iam_role_arn" {
  value = module.ec2.iam_role_arn
}
