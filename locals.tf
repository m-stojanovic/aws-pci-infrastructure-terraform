locals {
    public_count     = var.enabled && var.type_public == "public" ? length(var.availability_zones) : 0
    private_count    = var.enabled && var.type_private == "private" ? length(var.availability_zones) : 0
    private_db_count = var.enabled && var.type_private == "private" ? length(var.availability_zones) : 0
    policy_file      = templatefile("policy/policy.json", { name = var.var_name, dev_environment = var.var_dev_environment })
    operating_system = "AMAZON_LINUX_2"

  ingress_rules_main = [{
    port        = 22
    cidr_blocks = ["${var.vpc_cidr_bastion}","${var.vpc_cidr}"]
    description = "Bastion and Environment VPC"
  }]
  egress_rules_main = [{
    port        = 22
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Environment VPC"
  }]
  ingress_rules_web = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS traffic"
  }]
   egress_rules_web = [{
    port        = 8097
    cidr_blocks = ["0.0.0.0/0"]
    description = "Fintech GRPC"
  },
  {
    port        = 8080
    cidr_blocks = ["0.0.0.0/0"]
    description = "OS HTTP"
  },
  {
    port        = 8081
    cidr_blocks = ["0.0.0.0/0"]
    description = "OS GRPC"
  },
  {
    port        = 8082
    cidr_blocks = ["0.0.0.0/0"]
    description = "Octopush GRPC"
  },
  {
    port        = 8095
    cidr_blocks = ["0.0.0.0/0"]
    description = "UMS HTTP"
  },
  {
    port        = 8096
    cidr_blocks = ["0.0.0.0/0"]
    description = "UMS GRPC"
  }]
  ingress_rules_db = [{
    port        = 5432
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "PostgreSQL"
  }]
  ingress_rules_app = [{
    port        = 8097
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Fintech GRPC"
  },
  {
    port        = 8080
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OS HTTP"
  },
  {
    port        = 8081
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OS GRPC"
  },
  {
    port        = 8082
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Octopush GRPC"
  },
  {
    port        = 8095
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "UMS HTTP"
  },
  {
    port        = 8096
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "UMS GRPC"
  },
  {
    port        = 5672
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "RabbitMQ"
  },
  {
    port        = 6379
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "REDIS"
  }]
  egress_rules_app =[{
    port        = 5432
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Outbound PSQL access"
  },
  {
    port        = 8087
    cidr_blocks = ["3.249.164.170/32"]
    description = "NEXUS HTTPS"
  },
  {
    port        = 8096
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "UMS GRPC"
  },
  {
    port        = 8081
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OS GRPC"
  },
  {
    port        = 5672
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "RabbitMQ"
  },
  {
    port        = 6379
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "REDIS"
  },
  {
    port        = 465
    cidr_blocks = ["0.0.0.0/0"]
    description = "SMTP SERVER"
  }]
  egress_rules_updates = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS traffic"
  }]
  ingress_rules_bastion = [{
    port        = 2177
    cidr_blocks = ["54.75.194.40/32", "54.155.145.213/32", "217.24.19.64/29"]
    description = "Public IP of AccessTerminal and Jenkins"
    }]
  egress_rules_bastion = [{
    port        = 22
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "Environment VPC"
    },
    {
    port = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Traffic"
    },
    {
    port = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Traffic"
    }]
  ingress_rules_http_external_alb = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Traffic"
  }]
  egress_rules_http_external_alb = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Traffic"
  }]
  ingress_rules_http_internal_alb = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Traffic"
  },
  {
    port        = 8080
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OS HTTP"
  },
  {
    port        = 8082
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OCTOPUSH HTTP"
  },
  {
    port        = 8095
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "UMS HTTP"
  },
  {
    port        = 8097
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "FINTECH HTTP"
  },
  {
    port        = 5672
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "RabbitMQ"
  },
  {
    port        = 6379
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "REDIS"
  }]
  egress_rules_http_internal_alb = [{
    port        = 80
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP Traffic"
  },
  {
    port        = 443
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS Traffic"
  },
  {
    port        = 8080
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OS HTTP"
  },
  {
    port        = 8082
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "OCTOPUSH HTTP"
  },
  {
    port        = 8095
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "UMS HTTP"
  },
  {
    port        = 8097
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "FINTECH HTTP"
  },
  {
    port        = 5672
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "RabbitMQ"
  },
  {
    port        = 6379
    cidr_blocks = ["${var.vpc_cidr}"]
    description = "REDIS"
  }]
}