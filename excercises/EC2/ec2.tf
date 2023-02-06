provider "aws" {
  region = "ap-northeast-1"
  access_key = "${var.access_key}"
  secret_key = "${var.secret_key}"
}

resource "aws_instance" "ec2" {
  ami = "ami-0bba69335379e17f8"
  instance_type = "t2.micro"
}

resource "aws_eip" "lb" {
  instance = aws_instance.ec2.id
  vpc      = true
}

# output "eip" {
#   value = aws_eip.lb  
# }

# output "ec2output" {
#   value = aws_instance.ec2
# }

