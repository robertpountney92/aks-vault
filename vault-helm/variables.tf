# ---------------------------
# Azure Key Vault
# ---------------------------
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
  description = "Azure Kubernetes Service Cluster service principal password"
}