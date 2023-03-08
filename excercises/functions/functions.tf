provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

locals {
  time = formatdate("DD MMM YYYY hh:mm: ZZZ", timestamp())
}

# variable "region" {
#   default = "ap-northeast-1"
# }

variable "ami" {
  type = map(any)
  default = {
    "us-northeast-1" = "ami-0329eac6c5240c99d"
    "us-east-1"      = "ami-006dcf34c09e50022"
    "us-west-2"      = "ami-086b3de06dafe36c5"
  }
}

resource "aws_instance" "ec2" {
  ami           = lookup(var.ami, var.region)
  instance_type = "t2.micro"
}

resource "aws_eip" "lb" {
  instance = aws_instance.ec2.id
  vpc      = true
}

resource "aws_eip_association" "myeip" {
  instance_id   = aws_instance.ec2.id
  allocation_id = aws_eip.lb.id
}

output "ec2" {
  value = aws_instance.ec2.id
}

output "timestamp" {
  value = local.time
}


