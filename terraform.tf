terraform {
  required_providers {
    aws = {
      source  = "registry.terraform.io/hashicorp/aws"
      version = "~> 4.18.0"
    }
  }
  backend "s3" {
    bucket         = "terraform-288866261642"
    key            = "terraform_rds.tfstate"
    region = "us-west-2"
    dynamodb_table = "terraform-state-lock"
  }
}
provider "aws" {
  region = "us-west-2"
}


resource "aws_dynamodb_table" "terraform-state-lock" {
  name = "terraform_rds-state-lock"
  hash_key = "LockID"
  read_capacity = 5
  write_capacity = 5
  lifecycle {
    prevent_destroy = true
  }
  attribute {
    name = "LockID"
    type = "S"
  }
}
