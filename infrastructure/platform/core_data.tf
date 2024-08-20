data "azurerm_subnet" "vnet_subnet" {
  name                 = var.vnet_subnet_name
  virtual_network_name = var.vnet_name
  resource_group_name  = var.rg_name
}
