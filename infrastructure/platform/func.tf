resource "azurerm_service_plan" "func_sp" {
  name                = "${var.func_app_name}sp"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1v2"
}

resource "azurerm_subnet" "vnet_subnet_func" {
  name                 = "${var.vnet_name}subfunc"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vnet_subnet_func_prefixes

  delegation {
    name = "func-delegation"

    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_storage_account" "func_sta" {
  name                          = "${var.func_app_name}sta"
  resource_group_name           = azurerm_resource_group.rg.name
  location                      = azurerm_resource_group.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  shared_access_key_enabled     = true
  public_network_access_enabled = false
  dns_endpoint_type             = "Standard"
}

resource "azurerm_private_endpoint" "func_sta_pe" {
  name                = "${var.func_app_name}sta-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.func_app_name}sta-pe-service"
    private_connection_resource_id = azurerm_storage_account.func_sta.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }
  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.dns_zone1.id]
  }
}

resource "azurerm_linux_function_app" "func_app" {
  name                          = var.func_app_name
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  service_plan_id               = azurerm_service_plan.func_sp.id
  storage_account_name          = azurerm_storage_account.func_sta.name
  storage_uses_managed_identity = true
  https_only                    = true
  virtual_network_subnet_id     = azurerm_subnet.vnet_subnet_func.id

  site_config {
    application_insights_connection_string  = azurerm_application_insights.appi.connection_string
    application_insights_key                = azurerm_application_insights.appi.instrumentation_key
    http2_enabled                           = true
    elastic_instance_minimum                = 1
    container_registry_use_managed_identity = true
    application_stack {
      docker {
        registry_url = azurerm_container_registry.acr.login_server
        image_name   = var.image_name
        image_tag    = var.image_tag
      }
    }
    cors {
      allowed_origins = ["*"]
    }
  }

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
  }
}

resource "azurerm_private_endpoint" "func_pe" {
  name                = "${var.func_app_name}-pe"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.vnet_subnet.id

  private_service_connection {
    name                           = "${var.func_app_name}-pe-service"
    private_connection_resource_id = azurerm_linux_function_app.func_app.id
    is_manual_connection           = false
    subresource_names              = ["sites"]
  }
}

resource "azurerm_role_assignment" "func_is_funcsta_data_contributor" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.func_sta.id
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_is_sta_data_contributor" {
  role_definition_name = "Storage Blob Data Contributor"
  scope                = azurerm_storage_account.sta.id
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
}

resource "azurerm_role_assignment" "func_is_acr_puller" {
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
  principal_id         = azurerm_linux_function_app.func_app.identity[0].principal_id
}
