# main.tf
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "4.45.0"
    }
  }
}
provider "aws" {
  region  = "us-east-2" #The region where the environment
  #is going to be deployed # Use your own region here
  access_key = var.aws_access_key # Enter AWS IAM
  secret_key = var.aws_secret_key # Enter AWS IAM
}
