resource "azurerm_public_ip" "vm_public_ip" {
  name                = "${var.devops_vm_name}-pubip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "vm_nic" {
  name                = "${var.devops_vm_name}nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.devops_vm_name}-nic-ip-cfg"
    subnet_id                     = azurerm_subnet.vnet_subnet_gate.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  name                = var.devops_vm_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.vm_nic.id,
  ]
  size           = "Standard_F2"
  admin_username = var.devops_vm_username

  admin_ssh_key {
    username   = var.devops_vm_username
    public_key = file(var.devops_vm_ssh_pub_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  identity {
    type = "SystemAssigned"
  }
}

resource "azuread_group_member" "example" {
  group_object_id  = azuread_group.owners.id
  member_object_id = azurerm_linux_virtual_machine.vm.identity[0].principal_id
}
