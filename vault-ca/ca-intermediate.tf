resource "vault_mount" "pki_int" {
  path = "pki_int"
  type = "pki"
}

resource "vault_pki_secret_backend_intermediate_cert_request" "intermediate" {
  depends_on = [vault_mount.pki_int]

  backend = vault_mount.pki_int.path

  type        = "internal"
  common_name = "example.com Intermediate Authority"
}


resource "vault_pki_secret_backend_root_sign_intermediate" "signed" {
  backend = vault_mount.pki_root.path

  csr                  = vault_pki_secret_backend_intermediate_cert_request.intermediate.csr
  common_name          = "example.com"
  ttl                  = 2592000
}

resource "vault_pki_secret_backend_intermediate_set_signed" "intermediate" {
  backend = vault_mount.pki_int.path

  certificate = vault_pki_secret_backend_root_sign_intermediate.signed.certificate
}

resource "vault_pki_secret_backend_role" "role" {
  backend          = vault_mount.pki_int.path
  name             = "example-dot-com"
  allowed_domains  = ["example.com"]
  allow_subdomains = true
  max_ttl          = 2592000
}