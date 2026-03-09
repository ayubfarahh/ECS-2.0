resource "aws_wafv2_web_acl" "alb_waf" {
  name  = "alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "aws-managed-ip-reputation"
    priority = 1

    ## count just logs but dont block requests for this rule, none does whatever aws thinks is right 
    override_action {
      count {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "ipReputationList"
      sampled_requests_enabled   = true
    }
  }                        

  rule {                   
    name     = "rate-limit"
    priority = 2
    
    ## custom rules dont use overide action but action
    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = 100
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "rateLimit"
      sampled_requests_enabled   = true
    }
  }                        

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "albWaf"
    sampled_requests_enabled   = true
  }

}

resource "aws_wafv2_web_acl_association" "alb_waf_association" {
  web_acl_arn  = aws_wafv2_web_acl.alb_waf.arn
  resource_arn = var.alb_arn
}