
#########################################
#  Define RDS Postgresql Subnet Group   #
#########################################
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.var_name}-${var.var_dev_environment}-subnet-db-private"
  subnet_ids = aws_subnet.private_db_subnets.*.id
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-subnet-db-private"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#######################################
# Create RDS instance for fintech env #
#######################################
resource "aws_db_instance" "fintech_rds_instance" {
  allocated_storage          = 20
  storage_type               = "gp2"
  storage_encrypted          = "true"
  engine                     = "postgres"
  engine_version             = "12.6"
  auto_minor_version_upgrade = "true"
  parameter_group_name       = "default.postgres12"
  instance_class             = var.db_type
  identifier                 = "${var.var_name}-${var.var_dev_environment}-all-db"
  name                       = "fintech_server_db"
  username                   = var.var_username_db
  password                   = var.var_password_db
  multi_az                   = "true"
  backup_retention_period    = 31
  backup_window              = "04:00-04:30"
  maintenance_window         = "sun:04:30-sun:05:30"
  monitoring_interval        = 0
  iops                       = 0
  publicly_accessible        = "false"
  port                       = 5432
  ca_cert_identifier         = "rds-ca-2019"
  apply_immediately          = "true"
  skip_final_snapshot        = "false"
  final_snapshot_identifier  = "${var.var_name}-${var.var_dev_environment}-final-snapshot"
  copy_tags_to_snapshot      = true
  db_subnet_group_name       = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids     = [aws_security_group.db_sg.id]
  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-db-all"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

#########################################
#   Create databases on RDS instance    #
#########################################
# NOT POSSIBLE DUE AS LOCAL PC CAN NOT CONNECT TO THE APP PRIVATE SUBNET DIRECTLY THROUGH TERRAFORM
# EVEN IF THIS WAS DONE ON JENKINS SERVER IT WOULD NOT BE POSSIBLE FOR JENKINS SERVER DIRECTLY TO ACCESS PRIVATE SUBNET
# provider "postgresql" {
#   host             = aws_db_instance.fintech_rds_instance.address
#   alias            = "fintech"
#   database         = "postgres"
#   username         = aws_db_instance.fintech_rds_instance.username
#   password         = aws_db_instance.fintech_rds_instance.password
#   sslmode          = "disable"
#   expected_version = aws_db_instance.fintech_rds_instance.engine_version
# }

# resource "postgresql_database" "ums_db" {
#   count    = var.var_ums ? 1 : 0
#   provider = postgresql.fintech
#   name     = "ums_db"
# }

# resource "postgresql_database" "octopus" {
#   count    = var.var_octopus ? 1 : 0
#   provider = postgresql.fintech
#   name     = "octopus_server_db"
# }