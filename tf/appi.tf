resource "azurerm_application_insights" "appi" {
  name                = var.appi_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

resource "azurerm_private_endpoint" "appi_pe" {
  name                = "${var.appi_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.appi_name}-pe-service"
    private_connection_resource_id = azurerm_application_insights.appi.id
    is_manual_connection           = false
  }
}
