#
# cognito
#

resource "aws_api_gateway_authorizer" "authorizer" {
  count = var.use_cognito == false ? 0 : 1

  rest_api_id = aws_api_gateway_rest_api.this.id

  type  = "COGNITO_USER_POOLS"

  identity_source = "method.request.header.Authorization"
  name            = var.gateway_domain
  provider_arns   = [var.cognito_user_pool_arn]

#  tags = merge(var.project_tags)
}
