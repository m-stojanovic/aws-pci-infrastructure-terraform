###############
# AWS WAF ACL #
###############
resource "aws_wafv2_web_acl" "waf_managed_rules" {
  name  = "${var.var_name}-${var.var_dev_environment}-waf-protections"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.var_name}-${var.var_dev_environment}-waf-managed-rules-metric"
    sampled_requests_enabled   = true
  }

  rule {
    name     = "payquicker_webhook"
    priority = 0
    action {
      block {}
    }
    statement {
      and_statement {
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.payquicker_whitelisting.arn
              }
            }
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "/fintech-server/payquicker/webhook"
            text_transformation {
              priority = 0
              type     = "NONE"
            }

            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Payquicker_whitelist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "pqwebhook"
    priority = 1
    action {
      block {}
    }
    statement {
      and_statement {
        statement {
          not_statement {
            statement {
              ip_set_reference_statement {
                arn = aws_wafv2_ip_set.payquicker_whitelisting.arn
              }
            }
          }
        }
        statement {
          byte_match_statement {
            positional_constraint = "EXACTLY"
            search_string         = "/pqwebhook"
            text_transformation {
              priority = 1
              type     = "NONE"
            }

            field_to_match {
              uri_path {}
            }
          }
        }
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "Payquicker_whitelist"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesCommonRule"
    priority = 2
    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesCommonRuleSet"
      sampled_requests_enabled   = true
    }

  }

  rule {
    name     = "AWSManagedRulesAmazonIpReputation"
    priority = 3
    override_action {
      none {}
    }
    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }
    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "AWSManagedRulesAmazonIpReputation"
      sampled_requests_enabled   = true
    }
  }

    tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-waf-managed-rules"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

##############
# WAF IP Set #
##############
resource "aws_wafv2_ip_set" "payquicker_whitelisting" {
  name               = "payquicker_whitelisting"
  description        = "Payquicker webhook IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["40.121.219.206/32", "104.41.149.245/32"]

    tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-waf-payquicker-ip-set"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_wafv2_ip_set" "vpn_office_whitelisting" {
  name               = "vpn_office_whitelisting"
  description        = "VPN Office IP set"
  scope              = "REGIONAL"
  ip_address_version = "IPV4"
  addresses          = ["217.24.19.64/28"]

    tags = {
    Name               = "${var.var_name}-${var.var_dev_environment}-waf-vpn-ip-set"
    "user:Client"      = var.var_name
    "user:Environment" = var.var_dev_environment
  }
}

resource "aws_wafv2_web_acl_association" "alb_external_assoc" {
  resource_arn = aws_lb.alb_external_https.arn
  web_acl_arn  = aws_wafv2_web_acl.waf_managed_rules.arn
}

#################
# AWS GuardDuty #
#################
# S3 Protection (enable/disable) still not implemented in terraform
# Issue: https://github.com/hashicorp/terraform-provider-aws/issues/14607
resource "aws_guardduty_detector" "guard_detector" {
  enable = true
}