data "aws_acm_certificate" "cert" {
  domain   = "ecsv2.ayubs.uk"
  statuses = ["ISSUED"]
}

