variable "client_id" {
  description = "Client id value for AZ authentication"
  type        = string
  sensitive   = true
}

variable "client_secret" {
  description = "Client Secret for AZ authentication"
  type        = string
  sensitive   = true
}

variable "tenant_id" {
  description = "Tenant id for AZ authentication"
  type        = string
  sensitive   = true
}

variable "subscription_id" {
  description = "Subscription id for AZ authentication"
  type        = string
  sensitive   = true
}

variable "location" {
  description = "Cloud regions for AZ resources"
  type        = string
}

variable "app_name" {
  description = "Application name to be used in indentification on Azure"
  type        = string
}
