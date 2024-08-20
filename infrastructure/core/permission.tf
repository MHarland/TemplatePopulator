resource "azuread_group" "owners" {
  display_name     = "${var.project_name}-owners"
  owners           = var.owners_entra_object_ids
  security_enabled = true
  members          = var.owners_entra_object_ids
}

resource "azurerm_role_assignment" "data_owners" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_group.owners.object_id
}

resource "azurerm_role_assignment" "keyvault_admin" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = azuread_group.owners.object_id
}

resource "azurerm_role_assignment" "rsg_owner" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.owners.object_id
}

resource "azurerm_role_assignment" "owner_is_tf_state_sta_owner" {
  scope                = data.azurerm_storage_account.sta_tf_state.id
  role_definition_name = "Owner"
  principal_id         = azuread_group.owners.object_id
}

resource "azurerm_role_assignment" "owner_is_tf_state_sta_data_owner" {
  scope                = data.azurerm_storage_account.sta_tf_state.id
  role_definition_name = "Storage Blob Data Owner"
  principal_id         = azuread_group.owners.object_id
}



# resource "azuread_group" "subscription_reader" {
#   display_name     = "${var.project_name}-subscription-readers"
#   owners           = var.owners_entra_object_ids
#   security_enabled = true
# }

# resource "azurerm_role_assignment" "subscription_reader_is_reader" {
#   scope                = var.subscription_id
#   role_definition_name = "Reader"
#   principal_id         = azuread_group.subscription_reader.object_id
# }
