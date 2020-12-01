resource "kubernetes_namespace" "vault" {
  metadata {
    name = var.namespace
    labels = {
      mylabel = var.label
    }
  }
}

resource "kubernetes_secret" "azure_client_secret" {
  depends_on = [kubernetes_namespace.vault]

  metadata {
    name      = "azure-client-secret"
    namespace = kubernetes_namespace.vault.metadata[0].name
  }

  data = {
    "AZURE_CLIENT_SECRET" = var.app_password
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
  
  # Use this method to set environment variable to secret you inupt to TF config
  # set {
  #   name  = "server.extraEnvironmentVars.AZURE_CLIENT_SECRET"
  #   value = var.app_password
  # }

  # This method is more likely to be used, as it can set environment variable to exisiting K8s secret
  set {
    name  = "server.extraSecretEnvironmentVars[0].envName"
    value = "AZURE_CLIENT_SECRET"
  }
  set {
    name  = "server.extraSecretEnvironmentVars[0].secretName"
    value = "azure-client-secret"
  }
  set {
    name  = "server.extraSecretEnvironmentVars[0].secretKey"
    value = "AZURE_CLIENT_SECRET"
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