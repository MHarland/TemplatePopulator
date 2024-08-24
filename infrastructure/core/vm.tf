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
  "script": "H4sIAJ/yyWYCA5WU207cMBCG7/MUU1jRRcVxb1AlJCqtWISQKFRF6k1ByLEnibWObfnAoeLhsZPsbmk5dK9ij2f+3x5/zvYHWklNK+bbwmMAgkWxDVL7wJSCRoY9YL+jQ+BK7kFA51htXLcHwvAFusJHYYDZQJpUHK1gAZ/HllLkIauRNCx4dGnuz6ANwfoDStmClZ2np0PqLPsdnZ3OsYJH6MX67b3kBTs78KqdjrYBb+pwxxwS64xFFyR6wk3XGV3c5QJyQdb7sKF0qJB59GWbPCU3zpYpnTZJ6hGuivwlRCBznXF9pLcPiECjd9S3yYsu8MFJ3Xi6EiHM8VbeIhmXyiz0FajAW6pjasogrE3SrllUYZmYHMhqvLlFrq7TBJ1NsVAgbw1sidTaX142GgWpHg43lr1Ouu83DSZT5aubcREI97vQMam3/uobBp5VqDfR8SSipA+lWO+gD2xE2orTDPNMCJj3tH70YOpacskUnHw/gXSig410OSM8M5Q0UpqHTPKQvErq4POX/X0gYn2uZU+HzIH+2l+u+RfmTivDRDk8qh44JXW8p7GKOsSePmL+VaRjAfN8FG87I4B9cm/njl0JLYJDa7wMxqWuGZjZAOM1HAysXBUw8pI5OJxMhV1kUnucBjYC8pCe7C78QdQb7tf/fe7efDIth8MYT5YopVc/gDz5efzj8vTi/OboYn58Pvt2vJV2EVilcIAM4F3MRu88e/YgX+LiVTAGkQTHekTSHxO40SERj06U0izXqiiVuCdWxUbqVYHp0kXgGC2eAHSBolWYBQAA"
 }
SETTINGS

}

output "devops_vm_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}
