terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.83"
    }
  }
}

provider "aws" {
  region = "ap-northeast-2"
  
  skip_metadata_api_check     = true
  skip_region_validation      = true
  skip_requesting_account_id = false
}