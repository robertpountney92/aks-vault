
resource "azuread_application" "vault" {
  name                       = "vault"
  homepage                   = "https://homepage"
  identifier_uris            = ["https://uri"]
  reply_urls                 = ["https://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
  type                       = "webapp/api"
  owners                     = [data.azurerm_client_config.current.object_id]

  app_role {
    allowed_member_types = [
      "User",
      "Application",
    ]

    description  = "Admins can manage roles and perform all task actions"
    display_name = "Admin"
    is_enabled   = true
    value        = "Admin"
  }

  oauth2_permissions {
    admin_consent_description  = "Allow the application to access example on behalf of the signed-in user."
    admin_consent_display_name = "Access example"
    is_enabled                 = true
    type                       = "User"
    user_consent_description   = "Allow the application to access example on your behalf."
    user_consent_display_name  = "Access example"
    value                      = "user_impersonation"
  }

  oauth2_permissions {
    admin_consent_description  = "Administer the example application"
    admin_consent_display_name = "Administer"
    is_enabled                 = true
    type                       = "Admin"
    value                      = "administer"
  }
}

resource "azuread_service_principal" "vault" {
  application_id               = azuread_application.vault.application_id
  app_role_assignment_required = false

  tags = [var.label]
}

resource "azurerm_role_assignment" "vault" {
  scope                            = data.azurerm_subscription.primary.id
  role_definition_name             = "Key Vault Contributor"
  principal_id                     = azuread_service_principal.vault.id
  skip_service_principal_aad_check = true
}

resource "azuread_application_password" "vault" {
  application_object_id = azuread_application.vault.id
  description           = "My managed password"
  value                 = var.app_password
  end_date              = "2099-01-01T01:02:03Z"
}