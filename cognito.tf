#
# cognito
#

resource "aws_api_gateway_authorizer" "authorizer" {
  for_each = var.cognito

  rest_api_id = aws_api_gateway_rest_api.this.id

  type  = "COGNITO_USER_POOLS"

  identity_source = "method.request.header.Authorization"
  name            = join("-", [var.gateway_domain, each.key])
  # FIXME: get a list where each.value.type == COGNITO_USER_POOLS
  provider_arns   = [each.value.authorizer_id]

#  tags = merge(var.project_tags)
}
