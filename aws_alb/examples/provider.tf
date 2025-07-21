terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.27"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
}