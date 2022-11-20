#
# cors
#
locals {
  cors_resource_ids = concat([
    aws_api_gateway_rest_api.this.root_resource_id,
#    aws_api_gateway_resource.routes[*].id
  ],
  [ for k, v in var.routes: aws_api_gateway_resource.routes[k].id ]
  )
}

resource "aws_api_gateway_method" "cors" {
  count = length(local.cors_resource_ids)
  resource_id   = local.cors_resource_ids[count.index]

  rest_api_id   = aws_api_gateway_rest_api.this.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "cors" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  count = length(local.cors_resource_ids)
  resource_id = local.cors_resource_ids[count.index]

  http_method = aws_api_gateway_method.cors[count.index].http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = <<EOF
{ "statusCode": 200 }
EOF
  }
}

resource "aws_api_gateway_method_response" "cors" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  count = length(local.cors_resource_ids)
  resource_id = local.cors_resource_ids[count.index]

  http_method = aws_api_gateway_method.cors[count.index].http_method

  status_code = "200"

  response_models = {
    "application/json" = "Empty"
  }

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = false
    "method.response.header.Access-Control-Allow-Methods" = false
    "method.response.header.Access-Control-Allow-Origin" = false
    "method.response.header.Access-Control-Allow-Credentials" = false
  }
}

resource "aws_api_gateway_integration_response" "cors" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  count = length(local.cors_resource_ids)
  resource_id = local.cors_resource_ids[count.index]

  http_method = aws_api_gateway_method.cors[count.index].http_method
  status_code = aws_api_gateway_method_response.cors[count.index].status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Credentials" = "'true'"
    "method.response.header.Access-Control-Allow-Headers" = "'${join(",", var.cors.allow_headers)}'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin" = join(",", var.cors.allow_origins)
  }
}
