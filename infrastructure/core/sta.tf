resource "azurerm_private_endpoint" "sta_tf_state_pe" {
  name                = "${var.sta_tf_state_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.sta_tf_state_name}-pe-service"
    private_connection_resource_id = data.azurerm_storage_account.sta_tf_state.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone1.id]
  }
}
