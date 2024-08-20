data "azurerm_subnet" "vnet_subnet" {
  name                 = var.vnet_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}

data "azurerm_private_dns_zone" "dns_zone1" {
  name = var.dns_zone1_name
}
