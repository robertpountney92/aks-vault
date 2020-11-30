resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
    labels = {
      mylabel = var.label
    }
  }
}

resource "helm_release" "vault" {
  depends_on = [kubernetes_namespace.vault]

  name      = "vault"
  chart     = "hashicorp/vault"
  namespace = var.namespace
  values = [
    file("values-raft.yaml")
  ]
  set {
    name  = "server.extraEnvironmentVars.AZURE_CLIENT_ID"
    value = data.terraform_remote_state.aks-cluster.outputs.sp_client_id
  }
  set {
    name  = "server.extraEnvironmentVars.AZURE_CLIENT_SECRET"
    value = var.app_password
  }
  set {
    name  = "server.extraEnvironmentVars.AZURE_TENANT_ID"
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