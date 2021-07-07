#
# domain redirect
#

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id = aws_api_gateway_rest_api.this.id
  domain_name = aws_api_gateway_domain_name.this.domain_name
  stage_name = aws_api_gateway_stage.this.stage_name
}

resource "aws_api_gateway_domain_name" "this" {
  domain_name = var.gateway_domain
  certificate_arn = var.certificate_arn
}
