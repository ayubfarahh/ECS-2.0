data "aws_route53_zone" "ecsv2_zone" {
  name         = "ecsv2.ayubs.uk.com"
  
}

resource "aws_route53_record" "ecsv2_record" {
    zone_id = data.aws_route53_zone.ecsv2_zone.zone_id
    name    = "ecsv2.ayubs.uk.com"
    type    = "A"
    
    alias {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
    }
  
}

