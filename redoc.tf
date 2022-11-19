#
# special handler for redoc path
#
resource "aws_api_gateway_resource" "redoc" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "redoc"
}

#
# redoc path methods
#
resource "aws_api_gateway_method" "redoc" {
  for_each = var.target_methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.redoc.id
  http_method   = each.key
  request_parameters = {
    "method.request.path.redoc" = true
    "method.request.header.host" = true
  }

  authorization = lookup(lookup(var.cognito, "redoc", tomap({authorizer_id=null, cognito_domain="", type="NONE"})), "type", "NONE")
  authorizer_id = lookup(lookup(aws_api_gateway_authorizer.authorizer, "redoc", tomap({})), "id", null)
}

resource "aws_api_gateway_integration" "redoc" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.redoc.id

  http_method = aws_api_gateway_method.redoc[each.key].http_method
  integration_http_method = aws_api_gateway_method.redoc[each.key].http_method
  type = "HTTP_PROXY"
  uri = "https://${var.target_domain}/redoc"

  # FIXME: these should be variables for the module, but have no use-case yet
  request_parameters =  {
    "integration.request.path.redoc" = "method.request.path.redoc"
    "integration.request.header.host" = "method.request.header.host"
    "integration.request.header.x-cognito-subscriber-username" = "context.authorizer.claims.username"
    "integration.request.header.x-cognito-subscriber-email" = "context.authorizer.claims.email"
    "integration.request.header.x-cognito-subscriber-id"    = "context.authorizer.claims.sub"
  }
}

resource "aws_api_gateway_method_response" "redoc" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.redoc.id
  http_method = aws_api_gateway_method.redoc[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = false
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
  }
}
