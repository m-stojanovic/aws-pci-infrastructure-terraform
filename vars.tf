####################
#       AWS        #
####################
variable "region" {
  type    = string
  default = "eu-central-1"
}

###################
#   Environment   #
###################
variable "var_name" {
  type    = string
  default = "fintech"
}

variable "var_dev_environment" {
  type    = string
  default = "stage"
}

####################
#     Networks     #
####################
variable "vpc_cidr" {
  default = "172.23.0.0/24"
}

variable "newbits" {
  default     = "4"
  description = "Number of additional bits with which to extend the prefix"
}

variable "enabled" {
  description = "Set to false to prevent the module from creating any resources"
  default     = "true"
}

variable "type_public" {
  type        = string
  default     = "public"
  description = "Type of subnets to create (`private` or `public`)"
}

variable "type_private" {
  type        = string
  default     = "private"
  description = "Type of subnets to create (`private` or `public`)"
}

variable "availability_zones" {
  type        = list(string)
  default     = ["eu-central-1a", "eu-central-1b"]
  description = "List of Availability Zones (e.g. `['eu-west-1a', 'eu-west-1b', 'eu-west-1c']`)"
}

####################
#   EC2 Instance   #
####################
variable "i_tags" {
  type    = list(string)
  default = ["1", "2"]
}

variable "i_type" {
  type    = string
  default = "t3.small"
}

#################
# LOAD BALANCER #
#################
variable "target_name" {
  type    = list(string)
  default = ["os", "octpsh", "ums", "fintech"]
}

variable "target_port" {
  type    = list(string)
  default = ["8081", "8082", "8096", "8097"]
}

####################
#       RDS        #
####################
variable "var_ums" {
  description = "If set to true, install UMS service"
  default     = "true"
}

variable "var_octopus" {
  description = "If set to true, install UMS service"
  default     = "true"
}

variable "db_type" {
  type    = string
  default = "db.t3.micro"
}

variable "var_username_db" {
  type    = string
  default = "testbrt"
}

variable "var_password_db" {
  type    = string
  default = "test123!"
}

#######
# ALB #
#######
variable "domain_name_app" {
  description = "Domain name of main app"
  type        = string
  default     = "stage.client_domain.com"
}
variable "domain_name_admin" {
  description = "Domain name of admin app"
  type        = string
  default     = "stageadmin.client_domain.com"
}

####################
#    S3 Buckets    #
####################
variable "s3bucket_name" {
  type        = list(string)
  default     = ["server-s3", "private-server-s3", "octopus-server-s3", "octopus-server-private-s3"]
  description = "List of S3 Buckets to create"
}

###################
#     BASTION     #
###################
variable "client_name" {
  type    = string
  default = "client_name"
}

variable "dev_environment_bastion" {
  type    = string
  default = "bastion"
}

variable "vpc_cidr_bastion" {
  default = "172.19.0.0/24"
}

 variable "i_type_bastion" {
  type    = string
  default = "t3.small"
}

variable "bastion_priv_ip" {
  default = "172.19.0.10"
}
##################################
# SSH KEYS AND USERS FOR BASTION #
##################################
# Enter required username accounts and insert public keys
variable "ssh_port" {
  type    = number
  default = 2177
}

variable "username_1_pub_ssh" {
  type    = string
  default = ""
}
variable "username_2_pub_ssh" {
  type    = string
  default = ""
}
variable "username_3_pub_ssh" {
  type    = string
  default = ""
}

variable "username_1" {
  type    = string
  default = ""
}
variable "username_2" {
  type    = string
  default = ""
}
variable "username_3" {
  type    = string
  default = ""
}