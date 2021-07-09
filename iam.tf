# ################
# # IAM SSM Role #
# ################
resource "aws_iam_role" "AmazonSSMRoleForInstancesQuickSetup" {
  name               = "AmazonSSMRoleForInstancesQuickSetup-${var.var_name}-${var.var_dev_environment}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  inline_policy {
    name   = "AmazonSSMManagedInstanceCore"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
        "Action": [
            "ssm:DescribeAssociation",
            "ssm:GetDeployablePatchSnapshotForInstance",
            "ssm:GetDocument",
            "ssm:DescribeDocument",
            "ssm:GetManifest",
            "ssm:GetParameter",
            "ssm:GetParameters",
            "ssm:ListAssociations",
            "ssm:ListInstanceAssociations",
            "ssm:PutInventory",
            "ssm:PutComplianceItems",
            "ssm:PutConfigurePackageResult",
            "ssm:UpdateAssociationStatus",
            "ssm:UpdateInstanceAssociationStatus",
            "ssm:UpdateInstanceInformation"
        ],
          Effect   = "Allow"
          Resource = "*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "ssmmessages:CreateControlChannel",
              "ssmmessages:CreateDataChannel",
              "ssmmessages:OpenControlChannel",
              "ssmmessages:OpenDataChannel"
          ],
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
              "ec2messages:AcknowledgeMessage",
              "ec2messages:DeleteMessage",
              "ec2messages:FailMessage",
              "ec2messages:GetEndpoint",
              "ec2messages:GetMessages",
              "ec2messages:SendReply"
          ],
          "Resource": "*"
        }
      ]
    })
  }

  inline_policy {
    name   = "AmazonSSMPatchAssociation"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          "Effect": "Allow",
          "Action": "ssm:DescribeEffectivePatchesForPatchBaseline",
          "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
          "Effect": "Allow",
          "Action": "ssm:GetPatchBaseline",
          "Resource": "arn:aws:ssm:*:*:patchbaseline/*"
        },
        {
          "Effect": "Allow",
          "Action": "tag:GetResources",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": "ssm:DescribePatchBaselines",
          "Resource": "*"
        }
      ]
    })
  }

  tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-test-role"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

############################
# AWS EC2 instance profile #
############################
resource "aws_iam_instance_profile" "ec2_linux_patch_profile" {
  name        = "${local.operating_system}_PATCH_PROFILE"
  role        = aws_iam_role.AmazonSSMRoleForInstancesQuickSetup.name
}