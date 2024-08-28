resource "azuread_application_registration" "devops_app" {
  display_name = var.devops_sp_app_name
}
resource "azurerm_key_vault_secret" "devopsvm_sp_client_id" {
  name         = "DevOpsVM-sp-client-id"
  value        = azuread_application_registration.devops_app.client_id
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe]
}

resource "azuread_application_password" "devops_app_secret" {
  application_id = azuread_application_registration.devops_app.id
}
resource "azurerm_key_vault_secret" "devopsvm_sp_secret" {
  name         = "DevOpsVM-sp-secret"
  value        = azuread_application_password.devops_app_secret.value
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe]
}

resource "azuread_service_principal" "devops_sp" {
  client_id                    = azuread_application_registration.devops_app.client_id
  app_role_assignment_required = false
  owners                       = var.owners_entra_object_ids
}

resource "azuread_group_member" "devops_sp_is_owner" {
  group_object_id  = azuread_group.owners.id
  member_object_id = azuread_service_principal.devops_sp.object_id
}

resource "azurerm_role_assignment" "devops_sp_is_subscription_reader" {
  scope                = "/subscriptions/${var.subscription_id}"
  role_definition_name = "Reader"
  principal_id         = azuread_service_principal.devops_sp.object_id
}

output "devops_sp_client_id" {
  value = azuread_application_registration.devops_app.client_id
}

output "devops_sp_client_secret" {
  value     = azuread_application_password.devops_app_secret.value
  sensitive = true
}
