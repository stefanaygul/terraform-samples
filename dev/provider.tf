# provider.tf
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 3.50.0"
    }
  }
  backend "s3" {
    bucket         = "ninja-terraform-state"
    dynamodb_table = "terraform_state_lock"
    region         = "us-east-1"
    key            = "dev/terraform.tfstate"
    profile        = "ninja"
    encrypt        = true
  }

}
provider "aws" {
  region                   = "us-east-1"
  shared_credentials_files = ["~/.aws/credentials"]
  profile                  = "ninja"
}