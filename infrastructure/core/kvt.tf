resource "azurerm_key_vault" "kvt" {
  name                       = var.kvt_name
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = var.tenant_id
  soft_delete_retention_days = 7
  purge_protection_enabled   = false
  sku_name                   = "standard"
  enable_rbac_authorization  = true
}

resource "azurerm_private_endpoint" "kvt_pe" {
  name                = "${var.kvt_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.kvt_name}-pe-service"
    private_connection_resource_id = azurerm_key_vault.kvt.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone1.id]
  }
}

resource "azurerm_key_vault_secret" "tenant_id" {
  name         = "tenant-id"
  value        = var.tenant_id
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe, azurerm_role_assignment.keyvault_admin, azuread_group_member.devops_sp_is_owner]
}

resource "azurerm_key_vault_secret" "subscription_id" {
  name         = "subscription-id"
  value        = var.subscription_id
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe, azurerm_role_assignment.keyvault_admin, azuread_group_member.devops_sp_is_owner]
}
