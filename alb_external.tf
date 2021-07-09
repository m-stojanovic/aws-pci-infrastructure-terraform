#############################################
# Define External Application Load Balancer #
#############################################
resource "aws_lb" "alb_external_https" {
    name               = "${var.var_name}-${var.var_dev_environment}-external-https-alb"
    load_balancer_type = "application"
    internal           = false
    subnets            = [aws_subnet.public_subnets[0].id, aws_subnet.public_subnets[1].id]
    security_groups    = [aws_security_group.http_alb_external_sg.id]

    tags = {
        Name               = "${var.var_name}-${var.var_dev_environment}-external-https-alb"
        "user:Client"      = var.var_name
        "user:Environment" = var.var_dev_environment
    }
}

###################################################
# Define Service Target Groups External HTTPS ALB #
###################################################
resource "aws_lb_target_group" "http-tg" {
  name     = "${var.var_name}-${var.var_dev_environment}-http-web-target"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id

  health_check {
    port                = "traffic-port"
    healthy_threshold   = 3
    unhealthy_threshold = 2
    interval            = 30
    protocol            = "HTTP"
    matcher             = 200
    path                = "/"
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-http-web-target"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##########################################################
# Attach WEB EC2 instances to External HTTP target group #
##########################################################
resource "aws_lb_target_group_attachment" "http-tg" {
  count            = length(aws_subnet.public_subnets)
  target_group_arn = aws_lb_target_group.http-tg.arn
  target_id        = aws_instance.ec2_webapp[count.index].id
  port             = 80
}

#############################################################
# Define Application Load Balancer External HTTPS Listeners #
#############################################################
resource "aws_lb_listener" "lb_listener_https_web" {
  load_balancer_arn = aws_lb.alb_external_https.arn
  protocol          = "HTTPS"
  port              = "443"
  ssl_policy        = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn   = aws_acm_certificate.admin_certificate.arn


  default_action {
    target_group_arn = aws_lb_target_group.http-tg.arn
    type             = "forward"
  }
}

#######################################
# AWS Certificate Manager issue certs #
#######################################
# AMAZON Issued Certificate #
# resource "aws_acm_certificate" "app_certificate" {
#   #domain_name       = "${var.domain_name_app}"
#   domain_name       = "${var.domain_name_app}"
#   validation_method = "DNS"

#     tags = {
#         Name               = "${var.var_name}-${var.var_dev_environment}-app-certificate"
#         "user:Client"      = var.var_name
#         "user:Environment" = var.var_dev_environment
#     }

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# LetsEncrypt Issued Certificate #
resource "aws_acm_certificate" "app_certificate" {
  private_key       = "${file("certificates/privkey1.pem")}"
  certificate_body  = "${file("certificates/cert1.pem")}"
  certificate_chain = "${file("certificates/chain1.pem")}"

    tags = {
        Name               = "${var.var_name}-${var.var_dev_environment}-app-certificate"
        "user:Client"      = var.var_name
        "user:Environment" = var.var_dev_environment
    }
}

resource "aws_acm_certificate" "admin_certificate" {
  domain_name       = "${var.domain_name_admin}"
  validation_method = "DNS"

    tags = {
        Name               = "${var.var_name}-${var.var_dev_environment}-admin-certificate"
        "user:Client"      = var.var_name
        "user:Environment" = var.var_dev_environment
    }

  lifecycle {
    create_before_destroy = true
  }
}

#####################################################
# AWS Load Balancer listener certificate attachment #
#####################################################
resource "aws_lb_listener_certificate" "app_cert_attachment" {
  listener_arn    = aws_lb_listener.lb_listener_https_web.arn
  certificate_arn = aws_acm_certificate.app_certificate.arn
}