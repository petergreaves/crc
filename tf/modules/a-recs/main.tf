data "aws_route53_zone" "selected" {
  name = "peter-greaves.net." # Replace with your hosted zone name
}

output "hosted_zone_id" {
  value = data.aws_route53_zone.selected.zone_id
}


resource "aws_route53_record" "www" {
  zone_id = data.hosted_zone_id
  name    = "about.peter-greaves.net."
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution. s3_distribution. domain_name
    zone_id                = aws_cloudfront_distribution. s3_distribution. hosted_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "about_a_rec" {
  zone_id = ${data.hosted_zone_id}  # Replace with your Route 53 hosted zone ID
  name    = "about.peter-greaves.net"
  type    = "A"
  ttl     = 300
  records = ["1.2.3.4"]  # Replace with the IP address
}
