provider "aws" {
  region     = var.region
  access_key = var.access_key
  secret_key = var.secret_key

}

resource "aws_security_group" "web_server" {
  name        = "web-server"
  description = "Allow incoming HTTP Connections"

  ingress {

    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]

  }

  egress {

    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }
}

resource "aws_instance" "web_server" {
  ami             = "ami-01cc34ab2709337aa"
  instance_type   = "t2.micro"
  count           = 2
  key_name        = "whizlabs-key"
  security_groups = "${aws_security_group.web_server.name}"

  user_data = <<-EOF

       #!/bin/bash

       sudo su

        yum update -y

        yum install httpd -y

        systemctl start httpd

        systemctl enable httpd

        echo "<html><h1> Welcome to Whizlabs. Happy Learning from $(hostname -f)...</p> </h1></html>" >> /var/www/html/index.html

        EOF


  tags = {

    Name = "instance-${count.index}"

  }

}

resource "aws_vpc" "default" {
  tags = {
    Name = "Default VPC"
  }
}

# data "aws_subnet_ids" "subnet" {
#     vpc_id = data.aws_vpc.default.vpc_id
# }

resource "aws_default_subnet" "default_az1" {
  availability_zone = var.region

}

resource "aws_lb_target_group" "target-group" {

  health_check {

    interval            = 10
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
    healthy_threshold   = 5
    unhealthy_threshold = 2

  }


  name        = "whiz-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  # vpc_id = data.aws_vpc.default.id
  vpc_id = aws_default_subnet.default_az1.id

}

############# Creating Application Load Balancer #############


resource "aws_lb" "application-lb" {

  name               = "whiz-alb"
  internal           = false
  ip_address_type    = "ipv4"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.web_server.id]
  # subnets = data.aws_subnet_ids.subnet.ids
  subnets = "${aws_default_subnet.default_az1.id}"

  tags = {
    Name = "whiz-alb"
  }

}

######################## Creating Listener ######################

resource "aws_lb_listener" "alb-listener" {

  load_balancer_arn = aws_lb.application-lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {

    target_group_arn = aws_lb_target_group.target-group.arn
    type             = "forward"

  }

}

################ Attaching Target group to ALB ################

resource "aws_lb_target_group_attachment" "ec2_attach" {

  count            = length(aws_instance.web_server)
  target_group_arn = aws_lb_target_group.target-group.arn
  target_id        = aws_instance.web_server[count.index].id

}
