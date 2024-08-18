# https://learn.microsoft.com/en-us/azure/private-link/private-endpoint-overview#private-link-resource

resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "vnet_subnet" {
  name                 = "${var.vnet_name}sub"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vnet_subnet_prefixes
}

resource "azurerm_subnet" "vnet_subnet_gate" {
  name                 = "${var.vnet_name}subgate"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.vnet_subnet_gate_prefixes
}

# resource "azurerm_firewall" "firewall_gate" {
#   name                = "${var.vnet_name}subgatefirewall"
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku_name            = "AZFW_VNet"
#   sku_tier            = "Standard"

#   ip_configuration {
#     name      = "configuration"
#     subnet_id = "AzureFirewallSubnet"
#   }
# }
