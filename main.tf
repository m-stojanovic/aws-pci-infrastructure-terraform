#######################
#       Provider      #
#######################
# Variables in main.tf are not allowed to be used. Please change client_name manually.
provider "aws" {
    region                  = var.region
    shared_credentials_file = "/home/ec2-user/.aws/credentials"
    profile                 = "awsprofile"
}
terraform {
  backend "s3" {
    bucket          = "client_name-terraform-state-stage"
    key             = "stage/terraform.tfstate"
    region          = "eu-west-1"
    dynamodb_table  = "client_name-terraform-state-lock-stage"
  }
}
