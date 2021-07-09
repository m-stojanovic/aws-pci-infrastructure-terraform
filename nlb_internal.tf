#########################################
# Define Internal Network Load Balancer #
#########################################
resource "aws_lb" "nlb_internal_grpc" {
    name               = "${var.var_name}-${var.var_dev_environment}-internal-grpc-nlb"
    load_balancer_type = "network"
    internal           = true
    subnets            = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
    enable_cross_zone_load_balancing = true

    tags = {
        Name               = "${var.var_name}-${var.var_dev_environment}-internal-grpc-nlb"
        "user:Client"      = var.var_name
        "user:Environment" = var.var_dev_environment
    }
}

##################################################
# Define Service Target Groups Internal GRPC NLB #
##################################################
resource "aws_lb_target_group" "os-grpc-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-os-grpc-target"
  port     = 8081
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    protocol            = "TCP"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-os-grpc-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_lb_target_group" "ums-grpc-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-ums-grpc-target"
  port     = 8096
  protocol = "TCP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    interval            = 30
    protocol            = "TCP"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-ums-grpc-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##########################################################
# Attach APP EC2 instances to internal GRPC target group #
##########################################################
resource "aws_lb_target_group_attachment" "os-grpc-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.os-grpc-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8081
}

resource "aws_lb_target_group_attachment" "ums-grpc-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.ums-grpc-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8096
}

########################################################
# Define Network Load Balancer Internal GRPC Listeners #
########################################################
resource "aws_lb_listener" "lb_listener_grpc_os" {
  load_balancer_arn = aws_lb.nlb_internal_grpc.arn
  protocol          = "TCP"
  port              = "8081"


  default_action {
    target_group_arn = aws_lb_target_group.os-grpc-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "lb_listener_grpc_ums" {
  load_balancer_arn = aws_lb.nlb_internal_grpc.arn
  protocol          = "TCP"
  port              = "8096"


  default_action {
    target_group_arn = aws_lb_target_group.ums-grpc-tg.arn
    type             = "forward"
  }
}
