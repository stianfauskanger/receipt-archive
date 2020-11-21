terraform {

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }

  backend "s3" {
    bucket         = "receipt-archive-tf-state"
    key            = "terraform.state"
    dynamodb_table = "terraform-remote-state"
    region         = "eu-north-1"
  }

}

provider "random" {
  version = "3.0.0"
}

provider "aws" {
  profile = "default"
  region  = "eu-north-1"
}

variable region { default = "eu-north-1" }
variable availability_zone_a { default = "eu-north-1a" }
variable availability_zone_b { default = "eu-north-1b" }
variable availability_zone_c { default = "eu-north-1c" }
variable lambdas_s3_bucket { default = "receipt-archive-src" }
variable lambdas_s3_key { default = "zipped_lambdas" }
