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
