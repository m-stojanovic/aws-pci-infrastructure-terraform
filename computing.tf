##############################
#     Create AWS keypair     #
##############################
resource "aws_key_pair" "pem" {
  key_name   = "${var.client_name}_${var.var_dev_environment}"
  public_key = "ssh-rsa client_name"
}

#################################
#    Create EC2 Webapp instance #
#################################
resource "aws_instance" "ec2_webapp" {
  count                       = length(aws_subnet.public_subnets)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.i_type
  key_name                    = aws_key_pair.pem.key_name
  security_groups             = [aws_security_group.web_sg.id, aws_security_group.main_sg.id, aws_security_group.allow_updates.id]
  subnet_id                   = aws_subnet.public_subnets[count.index].id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.ec2_linux_patch_profile.name
  depends_on                  = [aws_instance.ec2_bastion]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = "true"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_encryption_key.arn
  }

  volume_tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-web-volume-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-web-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
    "Patch Group"      = aws_ssm_patch_group.patch_group.id
  }
}

#####################################
#         Create Webapp EIP         #
#####################################
resource "aws_eip" "eip_web" {
  count      = length(aws_subnet.public_subnets)
  instance   = element(aws_instance.ec2_webapp.*.id, count.index)
  vpc        = true
  depends_on = [aws_internet_gateway.igw]
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-web-eip-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}


################################
#    Create EC2 App instance   #
################################
resource "aws_instance" "ec2_app" {
  count                       = length(aws_subnet.private_subnets)
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.i_type
  key_name                    = aws_key_pair.pem.key_name
  security_groups             = [aws_security_group.main_sg.id, aws_security_group.app_sg.id, aws_security_group.allow_updates.id]
  subnet_id                   = aws_subnet.private_subnets[count.index].id
  associate_public_ip_address = false
  iam_instance_profile        = aws_iam_instance_profile.ec2_linux_patch_profile.name
  depends_on                  = [aws_instance.ec2_bastion]

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = "true"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_encryption_key.arn
  }

  volume_tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-app-volume-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-app-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
    "Patch Group"      = aws_ssm_patch_group.patch_group.id
  }
}