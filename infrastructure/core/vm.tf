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
  "script": "H4sIAE1BzmYCA5WUbW8bNwzH39+nYN2gS9FIKtZ2BQK0gNE4mYEsLuZ0wNAWhizxzoLvpIMeHCfohx9Pd7bXLX3IK1EU9adI/aTHj8TSWLGUYVUEjMCwKB7Dh/dn4+sJzCfX19OriznMzkHeJY++WWyMj0nWi0aqlbG4wG1EG4yzML2CTcNjCdNz+Hv2YSdy/ft0DufTy8mjTtnYEGVdQ2XiSa8JqjYnENF7WTrfnIB2ao2+CEk7kG1kFR0rtVpG/Nq3k2K3nRojs1DJ0zxcwirGNpwKIdeSN0FM+9Bxl+/d5fQMl/AFslgu/L5c8OQJfDOdTW0FwZXxRnpkrXct+mgwMOWaxtniptvAZuxwjjZyjzXKgIGvKKdRzrecwkVFUl/gU9GNjGmUvnE+e3L6iAgiBS/CinKJNd56Y6sg9iJMerqJDbJhiXdCb0Fo3AibqCm9sHWkXcpUx10gZWB7++Eput0lTdC35IsFqpWDkabWfgymsqjZ8vbNg2U/k+6PmwZHx3VYLoZFYCo8hUYaO/pP3zCqTkUEl7wikdqEyPXhBNnxINL2nHYwj7WGs0zrLwFcWRplZA0X7y+AKjp9kK6STHUMkQaFBehI7oP3QQ08f/3qFTB9qGvX0z6yp78M8wP/2t3Y2knN+0eVgauNTVuRlsnGlOlj7v+KYtgggxrEV43TIJ/578cOXYkrBI+tCyY6T11zMG4jDNdw2rPyqYCBl46DN0fHul13pGacejYiqkhP9in8i6jvZP/803Xn5EfHvC/GBbZDiV59D/LRX5M/59PZ1eLd7GxyNf5jMqJTRLmssYcM4IeYDbm72VcP8j4uvglGL0JwHCxGPyYoZyMRj15z43Zry2RqvWVtnSpj9xtcQxeBg7comrU2vv97F3Qm14aFrJBesNJwnzt/ZqNdZzchhuxvpVqTwfMO1GRZjCIviRf815cv+PMczLKL5e6z7W8v2bDIo/S8uhsVNMLddlPCT0QXXFDhpak4fdtc+GQ74x9RWrKKxQYAAA=="
 }
SETTINGS

}

output "devops_vm_ip" {
  value = azurerm_public_ip.vm_public_ip.ip_address
}

resource "azurerm_key_vault_secret" "devops_vm_ip" {
  name         = "devops-vm-ip"
  value        = azurerm_public_ip.vm_public_ip.ip_address
  key_vault_id = azurerm_key_vault.kvt.id
  depends_on   = [azurerm_private_endpoint.kvt_pe]
}
