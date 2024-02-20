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
