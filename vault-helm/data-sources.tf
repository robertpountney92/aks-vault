data "azurerm_client_config" "current" {
}

data "terraform_remote_state" "aks-cluster" {
  backend = "local"

  config = {
    path = "../aks-cluster/terraform.tfstate"
  }
}

data "kubernetes_service" "vault_lb" {
  depends_on = [helm_release.vault]

  metadata {
    name      = "vault-ui"
    namespace = "vault"
  }
}
