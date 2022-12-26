resource "aws_vpc" "this" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.0.0/24"
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.this.id
  cidr_block = "10.0.1.0/24"
}

resource "aws_security_group" "this" {
  name   = format("tf-mod-elasticcahe-test-%s-sg", random_string.random.result)
  vpc_id = aws_vpc.this.id

  ingress {
    protocol    = "tcp"
    self        = true
    from_port   = 27017
    to_port     = 27017
    description = "allow elasticcahe port from self"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
