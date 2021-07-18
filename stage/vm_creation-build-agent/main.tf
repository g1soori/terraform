
# Remote backend  configured in storage account
terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-dev-state"
    key                   = "terraform-agent.tfstate"
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

resource "azurerm_public_ip" "ansible" {
    name                         = "${var.resource_prefix}-pubip"
    location                     = data.terraform_remote_state.dev_rg.outputs.location
    resource_group_name          = data.terraform_remote_state.dev_rg.outputs.rg_name
    allocation_method            = "Dynamic"

    tags = {
        environment = "stage"
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
  size                = "Standard_DS2_v2"
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
    sku       = "18.04-LTS"
    version   = "latest"
  }
  
  tags = {
      env = "dev"
      app = "ansible"
      owner = "jeewan"
    }
  
  # provisioner "file" {
  #       connection {
  #           type     = "ssh"
  #           host     = azurerm_linux_virtual_machine.cc.public_ip_address
  #           user     = "adminuser"
  #           password = "Jeewan@Cloudcover123"
  #       }

  #       source      = "index.html"
  #       destination = "/tmp/index.html"
  #   }

  provisioner "remote-exec" {
      connection {
          type     = "ssh"
          host     = azurerm_linux_virtual_machine.ansible.public_ip_address
          user     = "adminuser"
          password = "Terraform@1234"
      }

      inline = [
        "sudo apt-get update",
        "curl https://raw.githubusercontent.com/MicrosoftDocs/mslearn-azure-pipelines-build-agent/master/build-tools.sh > build-tools.sh",
        "sed -i 's/apt-get install -y nodejs npm jq/apt-get install -y nodejs jq/g' build-tools.sh",
        "chmod u+x build-tools.sh",
        "sudo ./build-tools.sh",
        "curl https://raw.githubusercontent.com/MicrosoftDocs/mslearn-azure-pipelines-build-agent/master/build-agent.sh > build-agent.sh",
        "export AZP_AGENT_NAME=agent-vm01",
        "export AZP_URL=https://dev.azure.com/TaispinPractice",
        export AZP_TOKEN=var.tocken,
        "export AZP_POOL=MyAgentPool",
        "export AZP_AGENT_VERSION=$(curl -s https://api.github.com/repos/microsoft/azure-pipelines-agent/releases | jq -r '.[0].tag_name' | cut -d 'v' -f 2)",
        "chmod u+x build-agent.sh",
        "sudo -E ./build-agent.sh"
      ]
  }
}
