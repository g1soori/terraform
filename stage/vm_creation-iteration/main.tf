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
    key                   = "terraform-vm-generic.tfstate"
  }
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




module "vm_creation" {
  source = "./module"

  server_count      = var.server_count
  subnet_id         = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}"]
  core_rg_name      = data.terraform_remote_state.dev_rg.outputs.rg_name
  resource_prefix   = var.resource_prefix
  admin_secret      = var.admin_secret

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