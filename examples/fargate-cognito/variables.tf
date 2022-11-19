variable "aws_access_key_id"     { type = string }
variable "aws_secret_access_key" { type = string }
variable "aws_region"            { type = string }

variable "project_name" { type = string }
variable "project_domain" { type = string }
variable "project_tags" { type = map }

variable "internal_domain" { type = string }
variable "api_domain" { type = string }
variable "auth_domain" { type = string }
