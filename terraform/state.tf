terraform {
  required_version = " ~> 0.12.31"
  backend "local" {
    path = "./terraform.tfstate"
  }
  required_providers {
    aws = "~> 3.76.0"
  }
}
