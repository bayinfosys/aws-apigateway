variable "name" { type = string }
variable "description" { type = string }

variable "target_domain" {
  type = string
  description = "endpoint to target with {proxy+}"
}

variable "target_methods" {
  type = set(string)
  description = "list of methods that we proxy. NB: each method is created separately (do not use ANY), otherwise CORS will fail"
  default = ["GET"]
}

variable "gateway_domain" {
  type = string
  description = "API gateway domain"
}

variable "cognito_domain" {
  type = string
  description = "cognito auth domain"
}

variable "cognito_user_pool_arn" {
  type = string
  description = "cognito authentication pool"
  default = ""
}

variable "deployment_stage_name" {
  type = string
  description = "stage name for the API deployment, i.e., dev, prod, etc"
}

variable "certificate_arn" {
  type = string
  description = "certificate covering the target_domain if https"
}

variable "cors" {
  type = object({
    allow_origins = list(string)
    allow_headers = list(string)
  })
  description = "cors settings for the API endpoint"
}

variable "cors_default_allow_headers" {
  type = list(string)
  description = "default http headers allowed by CORS for reference"
  default = ["Content-Type", "X-Amz-Date", "Authorization", "X-Api-Key", "X-Amz-Security-Token"]
}

variable "binary_media_types" {
  type = list(string)
  description = "media types which are accepted by the gateway in their transmitted encoding, e.g. multipart/form-data, image/png, etc"
  default = ["multipart/form-data"]
}

variable "tags" {
  type = map
  description = "tags to apply to created objects"
  default = {}
}

variable "use_cognito" {
  type = bool
  description = "create an API authorizer with cognito details"
  default = false
}
