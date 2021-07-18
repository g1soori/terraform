# Import main modules that contains resource group, network
module "core_modules" {
  source = "../../data-sources/"
}


# Remote backend  configured in storage account
terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-vm-ansible.tfstate"
  }
}

# Create virtual machines
resource "azurerm_network_interface" "ansible" {
  count = var.server_count

  name                = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}-nic"
  location            = var.location
  resource_group_name = module.core_modules.core_rg_name
  lifecycle {
    prevent_destroy = false
  }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = module.core_modules.subnet_id
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
  resource_group_name = module.core_modules.core_rg_name
  location            = var.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = "Password@2452"
  disable_password_authentication   = "false"
  network_interface_ids = [
    azurerm_network_interface.ansible[count.index].id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}-disk"
  }

  source_image_id = module.core_modules.image_id

  tags = {
      env = "dev"
      app = "ansible"
      owner = "jeewan"
    }
}

# Null resource for run the ansible playbooks
resource "null_resource" "ansible" {
  count = var.server_count

  # Generate ansible dynamic inventory python script. 
  provisioner "local-exec" {
    command = "./generate_inv.sh $hostname $ip"
    environment = {
      hostname = "${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}"
      ip = "${element(azurerm_linux_virtual_machine.ansible.*.private_ip_address, count.index)}"
    }
  }
  
  # Run the ansible playbook
  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i $file resolv_correction.yml"
    environment = {
      file = "/tmp/${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}.py"
    }
  }

  # Delete the temporarily script file created in above step
  provisioner "local-exec" {
    command = "rm -f $file"
    environment = {
      file = "/tmp/${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}.py"
    }
  }

  depends_on = [
    azurerm_linux_virtual_machine.ansible,
  ]
}