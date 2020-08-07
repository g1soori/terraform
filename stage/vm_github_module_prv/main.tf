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
    key                   = "terraform-vm-generic_github_priv.tfstate"
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
  source = "git::https://github.com/g1soori/az_tf_vm_prv.git"

  server_count      = var.server_count
  subnet_id         = data.terraform_remote_state.subnet.outputs.subnet_id["${var.environment}"]
  core_rg_name      = data.terraform_remote_state.dev_rg.outputs.rg_name
  resource_prefix   = var.resource_prefix
  admin_secret      = var.admin_secret

}
