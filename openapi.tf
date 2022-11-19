#
# special handler for openapi.json resource
#
resource "aws_api_gateway_resource" "openapi" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "openapi.json"
}

#
# openapi path methods
#
resource "aws_api_gateway_method" "openapi" {
  for_each = var.target_methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.openapi.id
  http_method   = each.key
  request_parameters = {
    "method.request.path.openapi" = true
    "method.request.header.host" = true
  }

  authorization = lookup(var.cognito["openapi"], "type", "NONE")
  authorizer_id = lookup(aws_api_gateway_authorizer.authorizer["openapi"], "id", null)
}

resource "aws_api_gateway_integration" "openapi" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.openapi.id

  http_method = aws_api_gateway_method.openapi[each.key].http_method
  integration_http_method = aws_api_gateway_method.openapi[each.key].http_method
  type = "HTTP_PROXY"
  uri = "https://${var.target_domain}/openapi.json"

  # FIXME: these should be variables for the module, but have no use-case yet
  request_parameters =  {
    "integration.request.path.openapi" = "method.request.path.openapi"
    "integration.request.header.host" = "method.request.header.host"
    "integration.request.header.x-cognito-subscriber-username" = "context.authorizer.claims.username"
    "integration.request.header.x-cognito-subscriber-email" = "context.authorizer.claims.email"
    "integration.request.header.x-cognito-subscriber-id"    = "context.authorizer.claims.sub"
  }
}

resource "aws_api_gateway_method_response" "openapi" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.openapi.id
  http_method = aws_api_gateway_method.openapi[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = false
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
  }
}
