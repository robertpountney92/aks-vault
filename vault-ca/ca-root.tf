resource "vault_mount" "pki_root" {
  path = "pki_root"
  type = "pki"
}

resource "vault_pki_secret_backend_root_cert" "root" {
  depends_on = [vault_mount.pki_root]

  backend = vault_mount.pki_root.path

  type                 = "internal"
  common_name          = "example.com"
  ttl                  = "315360000"
}

resource "vault_pki_secret_backend_config_urls" "config_urls" {
  backend                 = vault_mount.pki_root.path
  issuing_certificates    = ["http://127.0.0.1:8200/v1/pki/ca"]
  crl_distribution_points = ["http://127.0.0.1:8200/v1/pki/crl"]
}