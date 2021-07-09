########################
#         VPC          #
########################
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-vpc"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#########################
#    Internet Gateway   #
#########################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-igw"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##########################
#     Public Subnets     #
##########################
resource "aws_subnet" "public_subnets" {
  count                   = local.public_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.newbits, count.index + 1)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-public-subnet-${count.index + 1}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##########################
#     Private Subnets    #
##########################
resource "aws_subnet" "private_subnets" {
  count                   = local.private_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.newbits, count.index + 3)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-private-subnet-${count.index + 1}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#############################
#     Private DB Subnets    #
#############################
resource "aws_subnet" "private_db_subnets" {
  count                   = local.private_db_count
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = cidrsubnet(var.vpc_cidr, var.newbits, count.index + 5)
  map_public_ip_on_launch = true
  availability_zone       = element(var.availability_zones, count.index)

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-private-db-subnet-${count.index + 1}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##################################
# NAT Gateway for Private subnet #
##################################
resource "aws_nat_gateway" "nat_gw" {
  count         = length(aws_subnet.public_subnets)
  allocation_id = aws_eip.eip_nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-nat-gw-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##############################
#     Create EIP NAT GW      #
##############################
resource "aws_eip" "eip_nat" {
  count      = length(aws_subnet.private_subnets)
  vpc        = true
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-nat-eip-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#################################
#      Routing Table Public     #
#################################
resource "aws_route_table" "route_table_public" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route {
    cidr_block = "172.19.0.0/24"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-public-rt"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##################################
#      Routing Table Private     #
##################################
resource "aws_route_table" "route_table_private" {
  count = length(aws_nat_gateway.nat_gw)
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
  route {
    cidr_block = "172.19.0.0/24"
    gateway_id = "aws_vpc_peering_connection.bastion_to_${var.var_dev_environment}.id"
  }
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-private-rt-${var.i_tags[count.index]}"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#####################################
#     Routing Table DB Private      #
#####################################
resource "aws_route_table" "route_table_db_private" {
  vpc_id = aws_vpc.vpc.id
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-private-db-rt-3"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##################################
# Route table association Public #
##################################
resource "aws_route_table_association" "assoc_route_table_public" {
  count          = length(aws_subnet.public_subnets)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.route_table_public.id
}

###################################
# Route table association Private #
###################################
resource "aws_route_table_association" "assoc_route_table_private" {
  count          = length(aws_subnet.private_subnets)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.route_table_private[count.index].id
}

######################################
# Route table association DB Private #
######################################
resource "aws_route_table_association" "assoc_route_table_db_private" {
  count          = length(aws_subnet.private_db_subnets)
  subnet_id      = aws_subnet.private_db_subnets[count.index].id
  route_table_id = aws_route_table.route_table_db_private.id
}

##########################
# VPC Peering connection #
##########################

resource "aws_vpc_peering_connection" "bastion_to_peering_vpc" {
  peer_vpc_id   = aws_vpc.vpc.id
  vpc_id        = aws_vpc.vpc_bastion.id
  auto_accept   = true

  tags = {
    Name = "${var.var_name}-bastion-${var.var_dev_environment}-peering"
  }
}

################################
# Main route table association #
################################
resource "aws_main_route_table_association" "main_rt_assoc" {
  vpc_id         = aws_vpc.vpc.id
  route_table_id = aws_route_table.route_table_db_private.id
}