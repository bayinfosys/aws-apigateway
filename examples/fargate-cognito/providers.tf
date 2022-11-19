terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}


provider "aws" {
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = var.aws_region
}

# cognito/buckets/etc require ACM certificates
# to be created in us-east (virginia)
# https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-pools-add-custom-domain.html
provider "aws" {
  alias = "us_east"
  access_key = var.aws_access_key_id
  secret_key = var.aws_secret_access_key
  region     = "us-east-1"
}
