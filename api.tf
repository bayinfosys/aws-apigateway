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
