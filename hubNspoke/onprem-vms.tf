##############################
# Onprem Site1 VM
##############################
resource "azurerm_network_interface" "onprem-site-1-vm-nic" {
  name                = "onprem-site-1-vm-nic"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name

  ip_configuration {
    name                          = "ipconfig"
    subnet_id                     = azurerm_subnet.onprem-site-1-vmsubnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "onprem-site-1-vm" {
  name                = "onprem-site-1-vm"
  location            = azurerm_resource_group.primary-rg.location
  resource_group_name = azurerm_resource_group.primary-rg.name
  size                = var.vm-size

  admin_username                  = var.vm-user
  admin_password                  = var.vm-password
  disable_password_authentication = false

  network_interface_ids = [azurerm_network_interface.onprem-site-1-vm-nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "OpenLogic"
    offer     = "CentOS"
    sku       = "8_5"
    version   = "latest"
  }
}


