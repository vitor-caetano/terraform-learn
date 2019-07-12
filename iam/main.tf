provider "aws" {
  region = "us-east-1"
}

terraform {
  required_version = "~> 0.11.2"

  backend "s3" {
    bucket = "vitor-learn-terraform-state"
    key    = "vitor-learn/us-east-1@tf0.11"
    region = "us-east-1"
  }
}

resource "aws_iam_policy" "robin-qa-policy" {
    name        = "robin-qa-policy"
    path        = "/"
    description = ""
    policy      = "${file("policies/robin-qa-policy.json")}"
}

resource "aws_iam_role" "robin-qa-role" {
    name               = "robin-qa-role"
    path               = "/"
    assume_role_policy = "${file("policies/robin-qa-assume-role-policy.json")}"
}

resource "aws_iam_policy_attachment" "robin-qa-policy-policy-attachment" {
    name       = "robin-qa-policy-policy-attachment"
    policy_arn = "${aws_iam_policy.robin-qa-policy.arn}"
    groups     = []
    users      = []
    roles      = ["robin-qa-role"]
}