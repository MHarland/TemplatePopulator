resource "azurerm_application_insights" "appi" {
  name                = var.appi_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}
