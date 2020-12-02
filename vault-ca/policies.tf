resource "vault_policy" "ca-issuer" {
  name   = "ca-issuer"
  policy = file("${path.root}/policies/ca-issuer.hcl")
}
