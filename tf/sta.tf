resource "azurerm_storage_account" "sta" {
  name                      = var.sta_name
  resource_group_name       = azurerm_resource_group.rg.name
  location                  = azurerm_resource_group.rg.location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "BlobStorage"
  enable_https_traffic_only = true
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
