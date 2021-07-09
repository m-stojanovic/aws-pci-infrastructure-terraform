##############################
#    Get AWS ami image id    #
##############################
data "aws_ami" "amazon_linux" {
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

###################################################
# Script to create required users on Bastion host #
###################################################
data "template_file" "kickstart_access_terminal" {
  template = file("./scripts/bastion_instances_startup.yaml")

  vars = {
    ssh_port          = var.ssh_port
    uros_pub_ssh      = var.uros_pub_ssh
    milos_pub_ssh     = var.milos_pub_ssh
    vladislav_pub_ssh = var.vladislav_pub_ssh
    username_1        = var.username_1
    username_2        = var.username_2
    username_3        = var.username_3
  }
}