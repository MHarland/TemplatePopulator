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
    type         = "UserAssigned"
    identity_ids = [azuread_service_principal.devops_sp.id]
  }
}

resource "azurerm_virtual_machine_extension" "vm_ext" {
  name                 = "${var.devops_vm_name}-extension"
  virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  # cat ./cicd/vm_setup.sh | gzip -9 | base64 
  settings = <<SETTINGS
 {
  "script": "H4sIAMSyx2YCA5WSz0sdMRDH7/krxmcRC2ZzFxSKPVSwtAdvtkg2mbcbzCZhJlGe+Mc7u/re04IUT5PMj893mJnDA9OHZHrLo2KsoFGpQwiJq40RhlBPwD42QnAxnEBFIrvONCluPoMtFVrxtuL+/6ZUi1WuUQTNVzDWWvjUGHtnu4nN5Uvetxl+cXX5HXt4goWy9LID6gG3InB0BO/cWy29gSG1MgDndX2whLpQLkg1IGuXpykn9TAX6F9630epHWFEy8jdKJrBZSqdpJtBUE/wR81Wa4+WpkyLZ5GviGAak+FRtMwdbiikgc0Ooi25Mdyjfg11M+gcjMd7k5oM5QWcsrDXtsW6TRQFvXt/XmKuXssHqYivKnRjhpWX0d5wGBJ63W/OPo39K9z/Dw2+HEfub1+DoB1/hcmGtPpnbljdTDGcGzmBxMC18/sOFseH5/Vu7ftrlJOdAy57VHJ4cqw54W7T4hlbv2z25w9L0SZvrnEqUci/c2liM3WSpZ4BQgkUDw4DAAA="
 }
SETTINGS

}

output "devops_vm_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
