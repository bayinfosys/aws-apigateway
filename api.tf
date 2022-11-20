#
# AWS API Gateway for services
#
#   services are hosted in ECS Fargate
#   and accessed via the API Gateway
#   We could not use a public ALB because
#   the ALB does not support CORS.
#
resource "aws_api_gateway_rest_api" "this" {
  name = var.name
  description = var.description

  binary_media_types = var.binary_media_types

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


resource "aws_api_gateway_method" "root" {
  for_each = var.target_methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_rest_api.this.root_resource_id
  http_method   = each.key
  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.header.host" = true
  }

  # NB: we need to make a 'fake object' which matches the var.cognito value object for lookup to work
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "root" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id

  http_method = aws_api_gateway_method.root[each.key].http_method
  integration_http_method = aws_api_gateway_method.root[each.key].http_method
  type = "HTTP_PROXY"
  uri = "https://${var.target_domain}/"

  # FIXME: these should be variables for the module, but have no use-case yet
  request_parameters =  {
    "integration.request.header.host" = "method.request.header.host"
    "integration.request.header.x-cognito-subscriber-username" = "context.authorizer.claims.username"
    "integration.request.header.x-cognito-subscriber-email" = "context.authorizer.claims.email"
    "integration.request.header.x-cognito-subscriber-id"    = "context.authorizer.claims.sub"
  }
}

resource "aws_api_gateway_method_response" "root" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_rest_api.this.root_resource_id
  http_method = aws_api_gateway_method.root[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = false
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
  }
}
