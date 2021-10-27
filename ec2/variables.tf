variable "subnet_id" {
  type = string
}

variable "security_group_ids" {
  type = list(string)
}

variable "name" {
  type = string
}

variable "zone_name" {
  type = string
}

variable "email_address" {
  type        = string
  description = "If set, OAuth2 Proxy will only authenticate supplied email address rather than entire org/account of the Oauth2 provider"
}

variable "github_username" {
  type        = string
  description = "GitHub username for importing public SSH keys associated to the GitHub account"
}

variable "oauth2_client_id" {
  type        = string
  description = "OAuth2 client ID key for chosen OAuth2 provider"
}

variable "oauth2_client_secret" {
  type        = string
  description = "OAuth2 client secret key for chosen OAuth2 provider"
}

variable "oauth2_provider" {
  type        = string
  description = "OAuth2 provider"
  default     = "google"
}

variable "region" {
  type        = string
  description = "AWS regional endpoint"
  default     = "us-east-1"
}
