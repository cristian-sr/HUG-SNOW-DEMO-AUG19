provider "aws" {
  region = "us-west-2"
}

resource "aws_s3_bucket" "example" {
  bucket = "tuffner01-bucket"
  acl = "private"
  versioning {
    enabled = false
  }  
}
