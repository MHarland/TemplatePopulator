resource "azurerm_storage_account" "sta" {
  name                          = var.sta_name
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  enable_https_traffic_only     = true
  public_network_access_enabled = false
  dns_endpoint_type             = "Standard"
}

resource "azurerm_storage_container" "templates" {
  name                  = "templates"
  storage_account_name  = azurerm_storage_account.sta.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "documents" {
  name                  = "documents"
  storage_account_name  = azurerm_storage_account.sta.name
  container_access_type = "private"
}

output "test_storage_endpoint" {
  value = azurerm_storage_account.sta.primary_blob_endpoint
}

output "test_storage_template_container" {
  value = azurerm_storage_container.templates.name
}

output "test_storage_document_container" {
  value = azurerm_storage_container.documents.name
}

resource "azurerm_private_endpoint" "sta_pe" {
  name                = "${var.sta_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = data.azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.sta_name}-pe-service"
    private_connection_resource_id = azurerm_storage_account.sta.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone1.id]
  }
}
