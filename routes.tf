#
# routes resources
#

resource "aws_api_gateway_resource" "routes" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  parent_id   = aws_api_gateway_rest_api.this.root_resource_id
  path_part   = each.value.path_part
}

#
# cognito
#
resource "aws_api_gateway_authorizer" "authorizer" {
  for_each = { for k,v in var.routes : k => v if v.authorizer.authorization == "COGNITO_USER_POOLS" }

  rest_api_id = aws_api_gateway_rest_api.this.id

  type = each.value.authorizer.authorization

  identity_source = "method.request.header.Authorization"
  name            = join("-", [var.gateway_domain, each.key])
  provider_arns   = [each.value.authorizer.authorizer_id]

#  tags = merge(var.project_tags)
}

#
# methods
#
resource "aws_api_gateway_method" "routes" {
  for_each = var.routes

  rest_api_id   = aws_api_gateway_rest_api.this.id
  resource_id   = aws_api_gateway_resource.routes[each.key].id
  http_method   = "ANY"  # each.key
  request_parameters = {
    "method.request.path.${each.key}" = true
    "method.request.header.host" = true
  }

  authorization = lookup(lookup(each.value, "authorizer", tomap({authorizer_id = null, cognito_domain = "", type = "NONE"})), "authorization")
  authorizer_id = lookup(lookup(aws_api_gateway_authorizer.authorizer, each.key, tomap({})), "id", null)
}

resource "aws_api_gateway_integration" "routes" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.routes[each.key].id

  http_method = aws_api_gateway_method.routes[each.key].http_method
  integration_http_method = aws_api_gateway_method.routes[each.key].http_method
  type = "HTTP_PROXY"
  uri = join("/", ["https:/", var.target_domain, each.value.uri])

  # FIXME: these should be variables for the module, but have no use-case yet
  request_parameters =  {
    "integration.request.path.${each.key}" = "method.request.path.${each.key}"
    "integration.request.header.host" = "method.request.header.host"

    "integration.request.header.x-cognito-subscriber-username" = "context.authorizer.claims.username"
    "integration.request.header.x-cognito-subscriber-email" = "context.authorizer.claims.email"
    "integration.request.header.x-cognito-subscriber-id"    = "context.authorizer.claims.sub"
  }
}

resource "aws_api_gateway_method_response" "routes" {
  for_each = var.routes

  rest_api_id = aws_api_gateway_rest_api.this.id
  resource_id = aws_api_gateway_resource.routes[each.key].id
  http_method = aws_api_gateway_method.routes[each.key].http_method
  status_code = "200"

#  response_parameters = {
#    "method.response.header.Access-Control-Allow-Credentials" = false
#    "method.response.header.Access-Control-Allow-Headers"     = false
#    "method.response.header.Access-Control-Allow-Methods"     = false
#    "method.response.header.Access-Control-Allow-Origin"      = false
#  }
}
