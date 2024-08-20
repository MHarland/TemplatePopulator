resource "azurerm_container_registry" "acr" {
  name                          = var.acr_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  sku                           = "Premium"
  admin_enabled                 = true
  anonymous_pull_enabled        = false
  network_rule_bypass_option    = "AzureServices"
  public_network_access_enabled = false
}

resource "azurerm_private_endpoint" "acr_pe" {
  name                = "${var.acr_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.acr_name}-pe-service"
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = ["registry"]
    is_manual_connection           = false
  }
}

output "image_upload_url" {
  value = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
}

output "acr_server" {
  value = azurerm_container_registry.acr.login_server
}