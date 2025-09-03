# Route 53 Hosted Zone Module
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = merge(
    {
      Name = var.zone_name
    },
    var.tags
  )
}

resource "aws_route53_record" "main" {
  count   = length(var.records)
  zone_id = aws_route53_zone.main.zone_id
  name    = var.records[count.index].name
  type    = var.records[count.index].type
  ttl     = var.records[count.index].ttl
  records = var.records[count.index].records
}

output "zone_id" {
  description = "The hosted zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "name_servers" {
  description = "The name servers for the hosted zone"
  value       = aws_route53_zone.main.name_servers
}