#########################
#    Security Groups    #
#########################
resource "aws_security_group" "main_sg" {
  name        = "${var.var_name}-${var.var_dev_environment}-main-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "SSH ports for EC2 single server"

  dynamic "ingress" {
    for_each = local.ingress_rules_main
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
  for_each = local.egress_rules_main
  content {
    from_port   = egress.value.port
    to_port     = egress.value.port
    protocol    = "TCP"
    cidr_blocks = egress.value.cidr_blocks
    description = egress.value.description
  }
}

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-main-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "web_sg" {
  name        = "${var.var_name}-${var.var_dev_environment}-web-sg"
  vpc_id      = aws_vpc.vpc.id
  description = "Web ports for EC2 single server"

  dynamic "ingress" {
    for_each = local.ingress_rules_web
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_web
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-web-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "app_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.var_name}-${var.var_dev_environment}-app-sg"
  description = "DB ports for EC2 single server"

  dynamic "ingress" {
    for_each = local.ingress_rules_app
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_app
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-app-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.var_name}-${var.var_dev_environment}-db-sg"
  description = "DB ports for EC2 single server"

  dynamic "ingress" {
    for_each = local.ingress_rules_db
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-db-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "allow_updates" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.var_name}-${var.var_dev_environment}-allow-updates-sg"
  description = "Allow system updates"

  dynamic "egress" {
    for_each = local.egress_rules_updates
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    "Name"             = "${var.var_name}-${var.var_dev_environment}-allow-updates-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "http_alb_external_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.var_name}-${var.var_dev_environment}-http-external-alb-sg"
  description = "SG for HTTP external ALB"

  dynamic "ingress" {
    for_each = local.ingress_rules_http_external_alb
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_http_external_alb
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    "Name"             = "${var.var_name}-${var.var_dev_environment}-http-external-alb-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_security_group" "http_alb_internal_sg" {
  vpc_id      = aws_vpc.vpc.id
  name        = "${var.var_name}-${var.var_dev_environment}-http-internal-alb-sg"
  description = "SG for HTTP internal ALB"

  dynamic "ingress" {
    for_each = local.ingress_rules_http_internal_alb
    content {
      from_port   = ingress.value.port
      to_port     = ingress.value.port
      protocol    = "TCP"
      cidr_blocks = ingress.value.cidr_blocks
      description = ingress.value.description
    }
  }

  dynamic "egress" {
    for_each = local.egress_rules_http_internal_alb
    content {
      from_port   = egress.value.port
      to_port     = egress.value.port
      protocol    = "TCP"
      cidr_blocks = egress.value.cidr_blocks
      description = egress.value.description
    }
  }

  tags = {
    "Name"             = "${var.var_name}-${var.var_dev_environment}-http-internal-alb-sg"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}
