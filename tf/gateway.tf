resource "azurerm_virtual_wan" "wan" {
  name                = "${var.project_name}-wan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_virtual_hub" "vhub" {
  name                = "${var.project_name}-vhub"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  virtual_wan_id      = azurerm_virtual_wan.wan.id
  address_prefix      = var.vhub_address_prefix
}

resource "azurerm_vpn_server_configuration" "vpn_server_config" {
  name                     = "${var.project_name}-vpn-scfg"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  vpn_authentication_types = ["AAD"]

  # https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-tenant
  azure_active_directory_authentication {
    audience = "41b23e61-6c1e-4545-b367-cd054e0ed4b4" # public
    issuer   = "https://sts.windows.net/${var.tenant_id}/"
    tenant   = var.tenant_id
  }
}

resource "azurerm_point_to_site_vpn_gateway" "vpn_gateway" {
  name                        = "${var.project_name}-vpn-gateway"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  virtual_hub_id              = azurerm_virtual_hub.vhub.id
  vpn_server_configuration_id = azurerm_vpn_server_configuration.vpn_server_config.id
  scale_unit                  = 1
  connection_configuration {
    name = "${var.project_name}-vpn-gateway-config"

    vpn_client_address_pool {
      address_prefixes = var.vpn_client_address_pool_prefixes
    }
  }
}

resource "azurerm_virtual_hub_connection" "vnet_to_vhub_connection" {
  name                      = "vnet-to-vhub-connection"
  virtual_hub_id            = azurerm_virtual_hub.vhub.id
  remote_virtual_network_id = azurerm_virtual_network.vnet.id
}
