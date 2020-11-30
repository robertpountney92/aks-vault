# ---------------------------
# Azure Key Vault
# ---------------------------
# variable "tenant_id" {
#   default = "58dea911-047d-43fb-9342-19ca17665d67"
# }

variable "key_name" {
  description = "Azure Key Vault key name"
  default     = "generated-key"
}

variable "location" {
  description = "Azure location"
  default     = "West US 2"
}

variable "environment" {
  default = "dev"
}

# ---------------------------
# Helm Chart
# ---------------------------
variable "namespace" {
  default = "vault"
}

variable "label" {
  default = "vault"
}

# ---------------------------
# Service Principal
# ---------------------------
variable "app_password" {
  default = "password"
}