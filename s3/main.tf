provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "vitor-learn-terraform-state"

  tags {
    Terraform_Name = "Terraform"
  }
}

output "bucket_name" {
  value = "${aws_s3_bucket.bucket.bucket}"
}

output "bucket_id" {
  value = "${aws_s3_bucket.bucket.id}"
}

output "bucket_arn" {
  value = "${aws_s3_bucket.bucket.arn}"
}
