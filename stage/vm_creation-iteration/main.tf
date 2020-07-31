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
    key                   = "terraform-vm-generic.tfstate"
  }
}

module "vm_creation" {
  source = "./module"

  resource_prefix   = var.resource_prefix
  server_count      = var.server_count
  subnet_id         = module.core_modules.subnet_id
  core_rg_name      = module.core_modules.core_rg_name
  image_id          = module.core_modules.image_id

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