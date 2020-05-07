
# ------------------------------------------------------------------------------
# the variables given below are populated via the backend.tfvars file
# see README.md for details
# ------------------------------------------------------------------------------

variable "region" {
  type = string
}

variable "bucket" {
  type = string
}

variable "dynamodb_table" {
  type = string
}
