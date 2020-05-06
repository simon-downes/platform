#
# Terraform file for creating resources needed to store state in S3
#

# this block should be commented out for the initial run, see README.md for info
terraform {
  backend "s3" {
    # these are specified in the backend.tfvars see README.md for details
    #bucket         = ""
    #dynamodb_table = ""
    #region         = ""
    key            = "global/state"
    encrypt        = true
  }
}

provider "aws" {
  region = var.state_region
}

# ------------------------------------------------------------------------------
# the variables given below are populated via the backend.tfvars file
# see README.md for details
# ------------------------------------------------------------------------------

variable "state_region" {
  type = string
}

variable "state_bucket" {
  type = string
}

variable "state_locktable" {
  type = string
}

# S3 bucket for storing state files
resource "aws_s3_bucket" "terraform_state" {

  bucket = var.state_bucket
  acl    = "private"

  # we want full revision history of our state files
  versioning {
    enabled = true
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

# DynamoDB table for handling locks
resource "aws_dynamodb_table" "terraform_locks" {
  name         = var.state_locktable
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "LockID"
  attribute {
    name = "LockID"
    type = "S"
  }
}
