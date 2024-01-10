resource "dnsimple_zone_record" "intro" {
  zone_name = var.base_domain
  name   = "gc"
  value  = var.intro
  type   = "A"
  ttl    = 600
}

resource "dnsimple_zone_record" "eu_central_1" {
  zone_name = var.base_domain
  name   = "eu-central-1.gc"
  value  = var.eu_central_1
  type   = "A"
  ttl    = 600
}

resource "dnsimple_zone_record" "af_south_1" {
  zone_name = var.base_domain
  name   = "af-south-1.gc"
  value  = var.af_south_1
  type   = "A"
  ttl    = 600
}

resource "dnsimple_zone_record" "ap_northeast_1" {
  zone_name = var.base_domain
  name   = "ap-northeast-1.gc"
  value  = var.ap_northeast_1
  type   = "A"
  ttl    = 600
}

resource "dnsimple_zone_record" "sa_east_1" {
  zone_name = var.base_domain
  name   = "sa-east-1.gc"
  value  = var.sa_east_1
  type   = "A"
  ttl    = 600
}
