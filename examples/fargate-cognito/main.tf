data "aws_route53_zone" "primary" {
  name  = var.project_domain
  private_zone = false
}

resource "aws_cognito_user_pool" "users" {
  name = "${var.project_name}"
  tags = merge(var.project_tags, {})

  password_policy {
    minimum_length = 6
    require_lowercase = true
    require_numbers = false
    require_symbols = false
    require_uppercase = false
    temporary_password_validity_days = 7
  }
}

module "acm_us_east" {
  source  = "terraform-aws-modules/acm/aws"
  version = "~> 2.0"

  providers = {
    aws = aws.us_east
  }

  domain_name = var.project_domain
  zone_id     = data.aws_route53_zone.primary.zone_id

  subject_alternative_names = concat([
      join(".", [var.internal_domain, var.project_domain]),
      join(".", [var.api_domain, var.project_domain]),
      join(".", [var.auth_domain, var.project_domain])
  ])

  wait_for_validation = true
  validation_allow_overwrite_records = true

  tags = merge(var.project_tags, {})
}

module "api_cognito_auth" {
  source = "../.."

  name = "${var.project_name}-auth-api"
  description = "example API gateway proxy for service authenticated by AWS cognito"

  target_domain = join(".", [var.internal_domain, var.project_domain])
  target_methods = ["GET"]

  cognito_domain = join(".", [var.auth_domain, var.project_domain])
  cognito_user_pool_arn = aws_cognito_user_pool.users.arn

  gateway_domain = join(".", [var.api_domain, var.project_domain])

  cors = {
    allow_origins = [
      "'https://${var.api_domain}.${var.project_domain}'",
      "'http://localhost:8080'"
    ]

    allow_headers = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
  }

  deployment_stage_name = "dev"
  certificate_arn = module.acm_us_east.this_acm_certificate_arn

  tags = merge(var.project_tags, {})
}

output "user-pool-id" {
  value = aws_cognito_user_pool.users.id
}
