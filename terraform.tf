terraform {
  required_version = ">= 1.0.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.27"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "2.4.2"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.1"
    }
  }
  backend "local" {
    path = "terraform.tfstate"
  }
}