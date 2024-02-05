# backend.tf

terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.my_state_bucket.bucket # Dynamically reference the bucket name
    key            = "terraform/state/"
    region         = "us-east-1" # Change this to your preferred AWS region
  }
}

