#
# deployment
#

resource "aws_api_gateway_deployment" "this" {
  rest_api_id = aws_api_gateway_rest_api.this.id

  triggers = {
    redeployment = sha1(jsonencode(concat([
      aws_api_gateway_rest_api.this,
      aws_api_gateway_resource.this,

      aws_api_gateway_method.cors,
      aws_api_gateway_method_response.cors,
      aws_api_gateway_integration.cors,
      aws_api_gateway_integration_response.cors
    ],
    [for k in var.target_methods: aws_api_gateway_method.default[k]],
    [for k in var.target_methods: aws_api_gateway_method_response.default[k]],
    [for k in var.target_methods: aws_api_gateway_integration.default[k]]
    )))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "this" {
  deployment_id = aws_api_gateway_deployment.this.id
  rest_api_id   = aws_api_gateway_rest_api.this.id
  stage_name    = var.deployment_stage_name
}
