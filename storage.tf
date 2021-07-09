##############################
# Create required S3 buckets #
##############################
resource "aws_s3_bucket" "s3_bucket" {
  for_each = toset(var.s3bucket_name)
  bucket   = "${var.var_name}-${var.var_dev_environment}-${each.key}"
  acl      = "private"

  versioning {
    enabled = false
  }

  server_side_encryption_configuration {
    rule {
      bucket_key_enabled  = true
      apply_server_side_encryption_by_default {
        kms_master_key_id = aws_kms_key.s3_encryption_key.arn
        sse_algorithm     = "aws:kms"
      }
    }
  }

  #policy = each.key == "private-server-test-s3" ? local.policy_file : null

  cors_rule {
    allowed_headers = ["*"]
    allowed_methods = ["PUT", "POST", "GET", "DELETE"]
    allowed_origins = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-${each.key}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}