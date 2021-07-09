########################
#         VPC          #
########################
resource "aws_vpc" "vpc_bastion" {
  cidr_block           = var.vpc_cidr_bastion
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-vpc"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}

#########################
#    Internet Gateway   #
#########################
resource "aws_internet_gateway" "igw_bastion" {
  vpc_id = aws_vpc.vpc_bastion.id
  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-igw"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}

##########################
#         Subnet         #
##########################
resource "aws_subnet" "public_subnets_bastion" {
  count                   = local.public_count
  vpc_id                  = aws_vpc.vpc_bastion.id
  cidr_block              = cidrsubnet(var.vpc_cidr_bastion, var.newbits, count.index)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-public-subnet-${count.index + 1}"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}

###########################
#      Routing Table      #
###########################
resource "aws_route_table" "route_table_public_bastion" {
  vpc_id = aws_vpc.vpc_bastion.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_bastion.id
  }
  route {
    cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 1) #"172.21.0.16/28"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  route {
    cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 2)#"172.21.0.32/28"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  route {
    cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 3)#"172.21.0.48/28"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  route {
    cidr_block = cidrsubnet(var.vpc_cidr, var.newbits, 4)#"172.21.0.64/28"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-public-rt"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}

###########################
# Route table association #
###########################
resource "aws_route_table_association" "assoc_route_table_subnets_public_bastion" {
  count          = length(aws_subnet.public_subnets_bastion)
  subnet_id      = aws_subnet.public_subnets_bastion[count.index].id
  route_table_id = aws_route_table.route_table_public_bastion.id
}

################################
# Main route table association #
################################
resource "aws_main_route_table_association" "bastion_main_rt_assoc" {
  vpc_id         = aws_vpc.vpc_bastion.id
  route_table_id = aws_route_table.route_table_public_bastion.id
}

#########################
#    Security Groups    #
#########################
resource "aws_security_group" "bastion_sg" {
  name        = "${var.client_name}-bastion-sg"
  vpc_id      = aws_vpc.vpc_bastion.id
  description = "SSH and Web ports for EC2 single server"

  dynamic "ingress" {
    for_each = local.ingress_rules_bastion
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_bastion
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
  }
}

  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-main-sg"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}

##############################
#     Create AWS keypair     #
##############################
resource "aws_key_pair" "pem_bastion" {
  key_name   = "ansible_bastion"
  public_key = "ssh-rsa ansible_host"
}

####################################
#    Create EC2 instance bastion   #
####################################
resource "aws_instance" "ec2_bastion" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.i_type_bastion
  key_name                    = aws_key_pair.pem_bastion.key_name
  security_groups             = [aws_security_group.bastion_sg.id]
  subnet_id                   = element(aws_subnet.public_subnets_bastion.*.id, 0)
  associate_public_ip_address = true
  private_ip                  = var.bastion_priv_ip
  iam_instance_profile        = aws_iam_instance_profile.ec2_linux_patch_profile.name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = "true"
    encrypted             = "true"
    kms_key_id            = aws_kms_key.ec2_encryption_key.arn
  }

  user_data = data.template_file.kickstart_access_terminal.rendered

  volume_tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-volume"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }

  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-ec2"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
    "Patch Group"      = aws_ssm_patch_group.patch_group.id
  }

  provisioner "remote-exec" {
    inline = ["sleep 80"]
  }

  connection {
    type        = "ssh"
    user        = "ec2-user"
    host        = self.public_ip
    port        = 2177
    private_key = file("./key/ansible_bastion.pem")
  }

  provisioner "local-exec" {
    command = "ansible-playbook --ssh-common-args='-o StrictHostKeyChecking=no -p 2177' -u ec2-user -i '${self.public_ip},' --private-key ./key/ansible_bastion.pem ./ansible/bastion_setup.yml"
  }
}

##############################
#         Create EIP         #
##############################
resource "aws_eip" "eip" {
  instance   = aws_instance.ec2_bastion.id
  vpc        = true
  depends_on = [aws_internet_gateway.igw_bastion]
  tags = {
    Name               = "${var.client_name}-${var.dev_environment_bastion}-eip"
    "user:Client"      = var.client_name
    "user:Environment" = var.dev_environment_bastion
  }
}