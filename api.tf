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
}

resource "aws_api_gateway_resource" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = "{proxy+}"
}

#
# methods
#
resource "aws_api_gateway_method" "default" {
  for_each = var.target_methods

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.this.id
  http_method   = each.key
  authorization = length(var.cognito_user_pool_arn) == 0 ? "NONE" : "COGNITO_USER_POOLS"
  request_parameters = {
    "method.request.path.proxy" = true
    "method.request.header.host" = true
  }

  authorizer_id = length(var.cognito_user_pool_arn) > 1 ? aws_api_gateway_authorizer.authorizer[0].id : null
}

resource "aws_api_gateway_integration" "default" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id

  http_method = aws_api_gateway_method.default[each.key].http_method
  integration_http_method = aws_api_gateway_method.default[each.key].http_method
  type = "HTTP_PROXY"
  uri = "https://${var.target_domain}/{proxy}"

  # FIXME: these should be variables for the module, but have no use-case yet
  request_parameters =  {
    "integration.request.path.proxy" = "method.request.path.proxy"
    "integration.request.header.host" = "method.request.header.host"
    "integration.request.header.x-cognito-subscriber-email" = "context.authorizer.claims.email"
    "integration.request.header.x-cognito-subscriber-id"    = "context.authorizer.claims.sub"
  }
}

resource "aws_api_gateway_method_response" "default" {
  for_each = var.target_methods

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.this.id
  http_method = aws_api_gateway_method.default[each.key].http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = false
    "method.response.header.Access-Control-Allow-Headers"     = false
    "method.response.header.Access-Control-Allow-Methods"     = false
    "method.response.header.Access-Control-Allow-Origin"      = false
  }
}
