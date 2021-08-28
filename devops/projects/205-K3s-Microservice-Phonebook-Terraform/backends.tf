terraform {
  backend "remote" {
    hostname     = "app.terraform.io"
    organization = "afsar"

    workspaces {
      name = "afsar-dev"
    }
  }
}