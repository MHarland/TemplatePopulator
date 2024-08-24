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
  "script": "H4sIABvGyWYCA5WSwWocMQyG734KZVNCA+vxPZBCaQ8JpDSH3toSPLZ2xqzHNpKdsCEPX80k2aWhoezJ9i/p+4Ws0xPTh2R6y6NirKBRqVMIiauNEYZQ12AfGyG4GNZQkchuMk2Km89gS9WDFLXibcW/tVeE3s0ULVflGsmbb2CstfCFMXZru4nN9XPq59nny831V+zhCRbY0ta/vODsDN61S60MwHlTHyyhLpQLUg3I2uVpykk9zAX6uz70UWpHGNEycjeKZ3CZSifpZhDUE/xS86m1R0tTpkVZ7CsimMZkeBQvs8UdhTSw2UO0JTeGe9QvoW4GfQLj8d6kJkN5Bqcs7I1tsb4mioPe34+3mKs38kAqolWFbsyw8jLanxyGhF73u8ujsb+F+/+hwYePkfu7lyBox+cw2ZBWb+aG1c0Uw7mRE0gMXDt/6GARjtq0w37KEs8xlz0q2T9Z35xw/+GijK1fPvjblaVokzc/cCpR4Le5NDkzdZKl/gBqSOOUIAMAAA=="
 }
SETTINGS

}

output "devops_vm_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
