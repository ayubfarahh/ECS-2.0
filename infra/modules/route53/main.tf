data "aws_route53_zone" "ecsv2_ayubs_uk" {
  name         = "ecsv2.ayubs.uk"
  
}

resource "aws_route53_record" "ecsv2_record" {
    zone_id = data.aws_route53_zone.ecsv2_ayubs_uk.zone_id
    name    = "ecsv2.ayubs.uk"
    type    = "A"
    
    alias {
        name                   = var.alb_dns_name
        zone_id                = var.alb_zone_id
        evaluate_target_health = true
    }
  
}

