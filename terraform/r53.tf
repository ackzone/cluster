resource "aws_route53_zone" "ack-zone-public" {
  name          = "ack.zone"
  comment       = "Managed by Terraform"
}

resource "aws_route53_record" "ack-zone-NS" {
    zone_id = "Z3QYCI7E2TAT9Q"
    name    = "ack.zone"
    type    = "NS"
    records = ["ns-905.awsdns-49.net.", "ns-1337.awsdns-39.org.", "ns-365.awsdns-45.com.", "ns-2022.awsdns-60.co.uk."]
    ttl     = "172800"
}

resource "aws_route53_record" "ack-zone-SOA" {
    zone_id = "Z3QYCI7E2TAT9Q"
    name    = "ack.zone"
    type    = "SOA"
    records = ["ns-905.awsdns-49.net. awsdns-hostmaster.amazon.com. 1 7200 900 1209600 86400"]
    ttl     = "900"
}
