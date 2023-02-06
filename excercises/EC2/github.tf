# terraform {
#   required_providers {
#     github = {
#       source  = "integrations/github"
#       version = "~> 5.0"
#     }
#   }
# }

# provider "github" {
#   owner = "github"
# }

# resource "github_repository" "terraform-testings" {
#   name        = "terraform-testings"
#   description = "terraform beginner"

#   visibility = "public"

# #   template {
# #     owner                = "github"
# #     repository           = "terraform-template-module"
# #     include_all_branches = true
# #   }
# }
