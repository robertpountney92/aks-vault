resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
    labels = {
      mylabel = var.label
    } 
  }
}


resource "helm_release" "vault" {
  depends_on = [ kubernetes_namespace.vault ]
  
  name  = "vault"
  chart = "hashicorp/vault"
  namespace = var.namespace
  values = [
    file("values-raft.yaml")
  ]
  set {
    name  = "server.extraEnvironmentVars.ARM_CLIENT_ID"
    value = azuread_service_principal.vault.application_id
  }
  set {
    name  = "server.extraEnvironmentVars.ARM_CLIENT_SECRET"
    value = var.app_password
  }
  # set {
  #   name  = "server.extraEnvironmentVars.ARM_SUBSCRIPTION_ID"
  #   value = data.azurerm_client_config.current.subscription_id
  # }
  set {
    name  = "server.extraEnvironmentVars.ARM_TENANT_ID"
    value = data.azurerm_client_config.current.tenant_id
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_AZUREKEYVAULT_VAULT_NAME"
    value = azurerm_key_vault.vault.name
  }
  set {
    name  = "server.extraEnvironmentVars.VAULT_AZUREKEYVAULT_KEY_NAME"
    value = var.key_name
  }
}