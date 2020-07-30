
terraform {
  backend "s3" {
    # these are specified in the backend.tfvars see README.md for details
    #bucket         = ""
    #dynamodb_table = ""
    #region         = ""
    key            = "global/artifacts"
    encrypt        = true
  }
}

provider "aws" {
  region = "eu-west-2"
}

data "aws_ssm_parameter" "artifact_bucket_param" {
  name = "sdc-artifact-bucket"
  with_decryption = true
}

# S3 bucket for storing artifacts
resource "aws_s3_bucket" "artifact_bucket" {

  bucket = data.aws_ssm_parameter.artifact_bucket_param.value
  acl    = "private"

  # we don't need revision history for build artifacts
  versioning {
    enabled = false
  }

  # enable encryption with S3-managed keys (SSE-S3)
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

}

# we want to ensure the bucket can't be made publically accessible
resource "aws_s3_bucket_public_access_block" "artifact_bucket_policy" {

  bucket = aws_s3_bucket.artifact_bucket.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls      = true
  restrict_public_buckets = true

}
