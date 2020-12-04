output "int_cert" {
    value = vault_pki_secret_backend_root_sign_intermediate.signed.certificate
}

output "root_ca" {
    value = vault_pki_secret_backend_root_cert.root.issuing_ca
}

