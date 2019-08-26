resource "aws_s3_bucket" "b" {
  bucket = "tuffy-tf-test-bucket"
  acl    = "private"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}
