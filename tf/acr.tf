resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Basic"
  admin_enabled       = false
}

output "image_upload_url" {
  value = "${azurerm_container_registry.acr.login_server}/${var.image_name}:${var.image_tag}"
}

output "acr_server" {
  value = azurerm_container_registry.acr.login_server
}
