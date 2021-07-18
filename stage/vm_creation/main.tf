# Import main modules that contains resource group, network
# module "rg" {
#   source = "../../data-sources/rg/"
# }

# module "network" {
#   source = "../../data-sources/network/"
# }

# Remote backend  configured in storage account
terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-vm1.tfstate"
  }
  required_version = ">= 0.12"
}

data "terraform_remote_state" "dev_rg" {
  backend = "azurerm"
  config = {
    resource_group_name   = "core"
    storage_account_name = "corestorageaccforlab"
    container_name       = "terraform-state"
    key                  = "terraform-dev-rg.tfstate"
  }
}

data "terraform_remote_state" "subnet" {
  backend = "azurerm"
  config = {
    resource_group_name   = "core"
    storage_account_name = "corestorageaccforlab"
    container_name       = "terraform-state"
    key                  = "terraform-vnet.tfstate"
  }
}

locals {
  standard_tags = {
    "prod" = "tfap"
    "azure" = "ansible"
  }
}

# Create public IP
resource "azurerm_public_ip" "ansible" {
  name                = "${var.resource_prefix}-vm01-pubip"
  resource_group_name = data.terraform_remote_state.dev_rg.outputs.rg_name
  location            = data.terraform_remote_state.dev_rg.outputs.location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}

# Create virtual machines
resource "azurerm_network_interface" "ansible" {
  #count = var.server_count

  #name                = "${var.resource_prefix}-vm${format("%02d",count.index + 1)}-nic"
  name                = "${var.resource_prefix}-vm01-nic"
  location            = data.terraform_remote_state.dev_rg.outputs.location
  resource_group_name = data.terraform_remote_state.dev_rg.outputs.rg_name
  lifecycle {
    prevent_destroy = false
  }

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}"]
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ansible.id
  }

  # dynamic "tags" {
  #   for_each = local.standard_tags

  #   content {
  #     env = tags.key
  #     app = tags.value
  #   }
  # }
}

# Create the virtual machine
resource "azurerm_linux_virtual_machine" "ansible" {
  #count = var.server_count

  name                = "${var.resource_prefix}-vm01"
  resource_group_name = data.terraform_remote_state.dev_rg.outputs.rg_name
  location            = data.terraform_remote_state.dev_rg.outputs.location
  size                = "Standard_B2s"
  admin_username      = "adminuser"
  admin_password      = var.admin_secret
  disable_password_authentication   = "false"
  network_interface_ids = [
    azurerm_network_interface.ansible.id,
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "${var.resource_prefix}-vm01-disk"
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

  provisioner "remote-exec" {
      connection {
          type     = "ssh"
          host     = azurerm_linux_virtual_machine.ansible.public_ip_address
          user     = "adminuser"
          password = "Terraform@1234"
      }

      inline = [
        "sudo apt-get update",
        "sudo apt-get install openjdk-8-jdk -y",
        "curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash"

      ]
  }
}

# # Null resource for run the ansible playbooks
# resource "null_resource" "ansible" {
#   count = var.server_count

#   # Generate ansible dynamic inventory python script. 
#   provisioner "local-exec" {
#     command = "./generate_inv.sh $hostname $ip"
#     environment = {
#       hostname = "${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}"
#       ip = "${element(azurerm_linux_virtual_machine.ansible.*.private_ip_address, count.index)}"
#     }
#   }
  
#   # Run the ansible playbook
#   provisioner "local-exec" {
#     command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i $file resolv_correction.yml"
#     environment = {
#       file = "/tmp/${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}.py"
#     }
#   }

#   # Delete the temporarily script file created in above step
#   provisioner "local-exec" {
#     command = "rm -f $file"
#     environment = {
#       file = "/tmp/${element(azurerm_linux_virtual_machine.ansible.*.name, count.index)}.py"
#     }
#   }

#   depends_on = [
#     azurerm_linux_virtual_machine.ansible,
#   ]
# }