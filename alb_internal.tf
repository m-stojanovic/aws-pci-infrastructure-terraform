#############################################
# Define Internal Application Load Balancer #
#############################################
resource "aws_lb" "alb_internal_http" {
    name               = "${var.var_name}-${var.var_dev_environment}-internal-http-alb"
    load_balancer_type = "application"
    internal           = true
    subnets            = [aws_subnet.private_subnets[0].id, aws_subnet.private_subnets[1].id]
    security_groups    = [aws_security_group.http_alb_internal_sg.id]

    tags = {
        Name               = "${var.var_name}-${var.var_dev_environment}-internal-http-alb"
        "user:Client"      = var.var_name
        "user:Environment" = var.var_dev_environment
    }
}

##################################################
# Define Service Target Groups Internal HTTP ALB #
##################################################
resource "aws_lb_target_group" "os-http-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-os-htpp-target"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/internal/check/health"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-os-http-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_lb_target_group" "ums-http-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-ums-http-target"
  port     = 8095
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/internal/check/health"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-ums-http-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_lb_target_group" "octpsh-http-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-octpsh-htpp-target"
  port     = 8082
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/internal/check/health"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-octpsh-http-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_lb_target_group" "fs-http-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-fs-htpp-target"
  port     = 8097
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = "200"
    path                = "/internal/check/health"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-fs-http-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

###########################################################
# Attach APP EC2 instances to internal HTTP target groups #
###########################################################
resource "aws_lb_target_group_attachment" "os-http-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.os-http-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8080
}
resource "aws_lb_target_group_attachment" "ums-http-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.ums-http-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8095
}
resource "aws_lb_target_group_attachment" "octpsh-http-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.octpsh-http-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8082
}
resource "aws_lb_target_group_attachment" "fs-http-tg" {
  count            = length(aws_subnet.private_subnets)
  target_group_arn = aws_lb_target_group.fs-http-tg.arn
  target_id        = aws_instance.ec2_app[count.index].id
  port             = 8097
}

############################################################
# Define Application Load Balancer Internal HTTP Listeners #
############################################################
resource "aws_lb_listener" "lb_listener_http_os" {
  load_balancer_arn = aws_lb.alb_internal_http.arn
  protocol          = "HTTP"
  port              = "8080"


  default_action {
    target_group_arn = aws_lb_target_group.os-http-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "lb_listener_http_ums" {
  load_balancer_arn = aws_lb.alb_internal_http.arn
  protocol          = "HTTP"
  port              = "8095"


  default_action {
    target_group_arn = aws_lb_target_group.ums-http-tg.arn
    type             = "forward"
  }
}
resource "aws_lb_listener" "lb_listener_http_octpsh" {
  load_balancer_arn = aws_lb.alb_internal_http.arn
  protocol          = "HTTP"
  port              = "8082"


  default_action {
    target_group_arn = aws_lb_target_group.octpsh-http-tg.arn
    type             = "forward"
  }
}

resource "aws_lb_listener" "lb_listener_http_fs" {
  load_balancer_arn = aws_lb.alb_internal_http.arn
  protocol          = "HTTP"
  port              = "8097"


  default_action {
    target_group_arn = aws_lb_target_group.fs-http-tg.arn
    type             = "forward"
  }
}
