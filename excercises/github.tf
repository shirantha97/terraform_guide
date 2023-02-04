terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 5.0"
    }
  }
}

provider "github" {
  token = "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"
}

resource "github_repository" "terraform-testings" {
  name        = "example"
  description = "terraform beginner"

  visibility = "private"

  template {
    owner      = "github"
    repository = "terraform-template-module"
    include_all_branches = true
  }
}
