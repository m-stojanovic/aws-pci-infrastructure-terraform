#######
# KMS #
#######
resource "aws_kms_key" "ec2_encryption_key" {
  description             = "Encryption key for volume storage"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name               = "EC2 encrpyion key"
    "user:Client"      = var.client_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_kms_key" "s3_encryption_key" {
  description             = "Encryption key for S3 storage"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  key_usage               = "ENCRYPT_DECRYPT"

  tags = {
    Name               = "S3 encrpyion key"
    "user:Client"      = var.client_name
    "user:Environment" = var.var_dev_environment
  }
}

############################
# KMS Encryption Key Alias #
############################
resource "aws_kms_alias" "ec2_encryption_key_alias" {
  name          = "alias/${var.var_dev_environment}-ec2-volume-key"
  target_key_id = aws_kms_key.ec2_encryption_key.key_id
}

resource "aws_kms_alias" "s3_encryption_key_alias" {
  name          = "alias/${var.var_dev_environment}-s3-storage-key"
  target_key_id = aws_kms_key.s3_encryption_key.key_id
}