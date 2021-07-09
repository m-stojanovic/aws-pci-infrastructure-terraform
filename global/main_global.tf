provider "aws" {
  region  = "eu-west-1"
  profile = var.profile
}

resource "aws_s3_bucket" "remote_tf_state" {
  bucket        = "${var.client_name}-terraform-state-${var.var_dev_environment}"
  force_destroy = true
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_dynamodb_table" "remote_tf_state_lock" {
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"
  name         = "${var.client_name}-terraform-state-lock-${var.var_dev_environment}"
  attribute {
    name = "LockID"
    type = "S"
  }
}
