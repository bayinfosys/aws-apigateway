module "simple_api" {
  source = ".."

  name = "${var.project_name}-simple-api"
  description = "API gateway proxy for simple service"

  target_domain = join(".", [var.internal_domain, var.project_domain])
  target_methods = ["ANY"]
  gateway_domain = join(".", [var.api_domain, var.project_domain])
  deployment_stage_name = "dev"
  certificate_arn = module.acm_us_east.this_acm_certificate_arn

  cors = {
    allow_origins = ["'*'"]
    allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
  }
}
