module "auth_api" {
  source = ".."

  name = "${var.project_name}-auth-api"
  description = "API gateway proxy for authenticated service"

  target_domain = join(".", [var.internal_domain, var.project_domain])
  target_methods = ["GET"]
  cognito_domain = join(".", [var.data_domain, var.project_domain])
  cognito_user_pool_arn = aws_cognito_user_pool.users.arn
  cors_allow_origins = ["'https://${var.frontend_domain}.${var.project_domain}'"]
  cors_allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
  deployment_stage_name = "dev"
  certificate_arn = module.acm_us_east.this_acm_certificate_arn
}
