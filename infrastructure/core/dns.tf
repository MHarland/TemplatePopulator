resource "azurerm_private_dns_zone" "dns_zone1" {
  name                = var.dns_zone1_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "dns_zone_blob_to_vnet" {
  name                  = "${azurerm_private_dns_zone.dns_zone1.name}-${var.vnet_name}"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.dns_zone1.name
  virtual_network_id    = azurerm_virtual_network.vnet.id
}
