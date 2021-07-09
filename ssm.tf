#################
# Patch manager #
#################
resource "aws_ssm_patch_baseline" "patch_baseline" {
  name             = "patch-baseline-${var.var_dev_environment}"
  description      = "Patch repository for ${local.operating_system}"
  operating_system = local.operating_system
  approved_patches = ["AWS-AmazonLinux2DefaultPatchBaseline"]
}

resource "aws_ssm_patch_group" "patch_group" {
  baseline_id = aws_ssm_patch_baseline.patch_baseline.id
  patch_group = "${var.var_name}-${var.var_dev_environment}-patch-group"
}

##################
# Resource group #
##################
# Change tag filter for environment type (test,development,stage,production)
resource "aws_resourcegroups_group" "mw_target_group" {
  name = "${var.var_name}-${var.var_dev_environment}-resource-group"

  resource_query {
    query = <<JSON
{
  "ResourceTypeFilters": [
    "AWS::EC2::Instance"
  ],
  "TagFilters": [
    {
      "Key": "user:Environment",
      "Values": ["stage","bastion"]
    }
  ]
}
JSON
  }
}

###########################
# SSM Maintainance window #
###########################
resource "aws_ssm_maintenance_window" "m_window" {
  name     = "${var.var_name}-${var.var_dev_environment}-maintenance-window"
  schedule = "cron(0 0 * * ? *)"
  duration = 3
  cutoff   = 1
}

resource "aws_ssm_maintenance_window_target" "instance_env" {
  window_id     = aws_ssm_maintenance_window.m_window.id
  name          = "${var.var_name}-${var.var_dev_environment}-mw-target"
  description   = "This is a maintenance window target"
  resource_type = "RESOURCE_GROUP"


  targets {
    key    = "resource-groups:Name"
    values = ["${var.var_name}-${var.var_dev_environment}-resource-group"]
  }
}