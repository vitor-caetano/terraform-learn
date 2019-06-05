provider "aws" {
  region = "us-east-1"
}

terraform {
    backend "s3" {
    bucket = "vitor-learn-terraform-state"
    key    = "vitor-learn/us-east-1"
    region = "us-east-1"
  }
}

module "ec2_module" {
//  source = "../modules/ec2"
  source = "github.com/vitor-caetano/terraform-modules/ec2"
}
