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

# Setting up this is messy with secrets
# resource "azurerm_virtual_machine_extension" "vm_ext" {
#   name                 = "${var.devops_vm_name}-extension"
#   virtual_machine_id   = azurerm_linux_virtual_machine.vm.id
#   publisher            = "Microsoft.Azure.Extensions"
#   type                 = "CustomScript"
#   type_handler_version = "2.0"

#   # cat ./cicd/vm_setup.sh | gzip -9 | base64 
#   settings = <<SETTINGS
#  {
#   "script": "H4sIAJqc1GYCA5WUa2/bOgyGv/tXcEmxdTiVVOwKFNgBgjXtAnTNsHQHGLYhUCTaEWJLhiSnabEfP1p2km2nu/STaZJ6KVKPNHwgFsaKhQzLLGAEhlk2hA/vTkdXY5iNr64ml+czmJ6BvG08+mq+Nj42spxXUi2NxTluItpgnIXJJawrHnOYnMHH6YetyNWbyQzOJhfjB62ysSHKsoTCxKNOE1RpjiCi9zJ3vjoC7dQKfRYa7UDWkRW0rabWMuKPvq0Uu2nVGJmZajz9hwtYxliHEyHkSvIqiEmXOmrrvb6YnOICvkISS43fVQsePoRflrNNXUBwebyWHlntXY0+GgxMuapyNrtuF7Ap2++jjtxjiTJg4EuqaZTzNad0UZDUV/ictV/GNEpfOZ88qXxEBNEEL8KSaokV3nhjiyB2Ikx6Ook1sj7EW6F/QWhcC9vQUDph60g7l00Zt4lUge3s+5doV+f0g74mX8xQLR0MNI32UzCFRc0WN6/uLfuFdP88NDg4LMNi3geBqfAYKmns4Ke5YVStigiu8YpEShMi1/sdJMe9SNtx2sI80hpOE62PArg8N8rIEs7fnQN1dHIvXSWZahkiDUoL0JLcJe+SKjh++fw5ML3vazvTLrOjPw+zPf/aXdvSSc27S5WAK41tNqJZNDY2iT7m/q8o+gUyqF58WTkN8h//+9x+KnGJ4LF2wUTnaWoORnWE/hhOOlY+Z9Dz0nLw6uBQ16uW1IRTx0ZEFenKPobviPpN9S9/3XcqfnDIu2ZcYFuU6NZ3IB/8N34/m0wv56+np+PL0dvxgHYR5aLEDjKAP2LW127/friQd3HxSzA6EYJjbzF6MUE5G4l49Jobt40tGlPqDavLpjB2t8BVdBDYe+mEqpU2vnt857QpV4e5LJCu8FBpuNOf3rPBdrjrEEMK1FKtyOBpCWqyLEaRQuIpf/LsKT9OySy5WDoAtnnxjPVBHqXnxe0gG5IBt5t1Dn+Rng25oO5zU3B6u+nHN7a1vgE8AC22ywYAAA=="
#  }
# SETTINGS
# }

output "devops_vm_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

resource "azurerm_key_vault_secret" "devops_vm_ip" {
  name         = "devops-vm-ip"
  value        = azurerm_public_ip.vm_public_ip.ip_address
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe, azurerm_role_assignment.keyvault_admin, azuread_group_member.devops_sp_is_owner]
}
