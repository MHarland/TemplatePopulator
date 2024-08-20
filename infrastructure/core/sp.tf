# resource "azuread_application" "devops_app" {
#   display_name = var.devops_sp_app_name
#   owners       = var.owners_entra_object_ids
# }

# resource "azuread_service_principal" "devops_sp" {
#   client_id                    = azuread_application.devops_app.client_id
#   app_role_assignment_required = false
#   owners                       = var.owners_entra_object_ids
# }

# resource "azuread_service_principal_password" "devops_sp_secret" {
#   service_principal_id = azuread_service_principal.devops_sp.object_id
# }
resource "azuread_application_registration" "devops_app" {
  display_name = var.devops_sp_app_name
}

resource "azuread_application_password" "devops_app_secret" {
  application_id = azuread_application_registration.devops_app.id
}

# resource "azuread_group_member" "devops_sp_is_owner" {
#   group_object_id  = azuread_group.owners.id
#   member_object_id = azuread_application_registration.devops_app.object_id
# }

output "devops_sp_client_id" {
  value = azuread_application_registration.devops_app.client_id
}

output "devops_sp_client_secret" {
  value     = azuread_application_password.devops_app_secret.value
  sensitive = true
}
