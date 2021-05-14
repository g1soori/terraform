# Create virtual machines
resource "azurerm_network_interface" "ansible" {
  count = var.server_count

  name                = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}-nic"
  location            = var.location
  resource_group_name = var.core_rg_name
  lifecycle {
    prevent_destroy = false
  }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
      env = "dev"
      app = "ansible"
      owner = "jeewan"
    }
}

# Create the virtual machine
resource "azurerm_linux_virtual_machine" "ansible" {
  count = var.server_count

  name                = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}"
  resource_group_name = var.core_rg_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = var.admin_secret
  disable_password_authentication   = "false"
  network_interface_ids = [
    azurerm_network_interface.ansible[count.index].id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}-disk"
  }

  # source_image_id = var.image_id
  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }
  
  tags = {
      env = "dev"
      app = "ansible"
      owner = "jeewan"
    }
}
