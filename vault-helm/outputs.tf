output "client_id" {
  value = azuread_service_principal.vault.application_id
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
output "azurerm_client_config" {
  value = data.azurerm_client_config.current.client_id
}

