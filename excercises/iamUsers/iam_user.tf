provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region     = var.region
}

resource "aws_iam_user" "terraform-users" {
  name  = "imauser.${count.index}"
  count = 2
  path  = "/system/"

  tags = {
    tag-key = "tag-value"
  }
}

output "iam-user-arn" {
  value = aws_iam_user.terraform-users[*].arn
}
