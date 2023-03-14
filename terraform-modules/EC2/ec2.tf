provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_security_group" "allowPorts" {
  name        = "allow port 22"
  description = "allow traffic from port 22"

  ingress {
    cidr_blocks = ["0.0.0.0/0"]
    description = "value"
    from_port   = 22
    to_port     = 22
    protocol = "tcp"
  }

}

resource "aws_instance" "provisioner-demo" {
  ami                    = var.instance_ami
  instance_type          = "t2.micro"
  key_name               = "terraform_provisioner"
  vpc_security_group_ids = [aws_security_group.allowPorts.id]

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install docker -y",
      "sudo systemctl start docker"
    ]
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "sudo systemctl stop docker"
    ]
  }

  connection {
    type        = "ssh"
    user        = "uec2-user"
    private_key = file("./terraform_provisioner.pem")
    host        = self.public_ip
  }

}
