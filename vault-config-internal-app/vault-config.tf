resource "vault_mount" "kv" {
  path        = "internal"
  type        = "kv-v2"
  description = "Mount KV secrets engine at path internal"
}

resource "vault_generic_secret" "internal" {
  depends_on = [vault_mount.kv]

  path      = "internal/database/config"
  data_json = <<EOT
{
  "username":   "${var.db_username}",
  "password":   "${var.db_password}"
}
EOT
}

resource "vault_auth_backend" "kubernetes" {
  type = "kubernetes"
}


module "vault-token" {
  source  = "matti/resource/shell"
  command = "kubectl get secrets -n vault | grep vault-token | awk 'NR==1 {print $1}'"
}


data "kubernetes_secret" "vault_token" {
  metadata {
    name      = module.vault-token.stdout
    namespace = "vault"
  }
}

data "kubernetes_service" "kubernetes" {
  metadata {
    name = "kubernetes"
  }
}

# The token_reviewer_jwt and kubernetes_ca_cert are mounted to the container by Kubernetes when it is created. 
# The environment variable KUBERNETES_PORT_443_TCP_ADDR is defined and references the internal network address of the Kubernetes host.
resource "vault_kubernetes_auth_backend_config" "example" {
  backend                = vault_auth_backend.kubernetes.path
  kubernetes_host        = "https://${data.kubernetes_service.kubernetes.spec[0].cluster_ip}:443"
  kubernetes_ca_cert     = data.kubernetes_secret.vault_token.data["ca.crt"]
  token_reviewer_jwt     = data.kubernetes_secret.vault_token.data.token
  issuer                 = "api"
  disable_iss_validation = "true"
}

resource "vault_policy" "internal-app" {
  name = "internal-app"

  policy = <<EOF
path "internal/data/database/config" {
  capabilities = ["read"]
}
EOF
}

resource "vault_kubernetes_auth_backend_role" "internal-app" {
  backend                          = vault_auth_backend.kubernetes.path
  role_name                        = "internal-app"
  bound_service_account_names      = ["internal-app"]
  bound_service_account_namespaces = ["vault"]
  token_policies                   = ["internal-app"]
  token_ttl                        = 86400
}

resource "kubernetes_service_account" "internal-app" {
  metadata {
    name = "internal-app"
    namespace = "vault"
  }
  automount_service_account_token = true
}