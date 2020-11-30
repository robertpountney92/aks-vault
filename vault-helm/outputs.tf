output "sp_client_id" {
  value = azuread_service_principal.vault.application_id
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "az_user_client_id" {
  value = data.azurerm_client_config.current.client_id
}

