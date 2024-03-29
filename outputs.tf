output "cloudfront_domain_name" {
  value = aws_api_gateway_domain_name.this.cloudfront_domain_name
}

output "cloudfront_zone_id" {
  value = aws_api_gateway_domain_name.this.cloudfront_zone_id
}

output "routes" {
  value = var.routes
}


output "auths" {
  value = aws_api_gateway_authorizer.authorizer
}
