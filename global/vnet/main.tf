terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "terraform-vnet.tfstate"
  }
}

data "terraform_remote_state" "rg" {
  backend = "azurerm"
  config = {
    resource_group_name   = "core"
    storage_account_name = "corestorageaccforlab"
    container_name       = "terraform-state"
    key                  = "terraform-core-rg.tfstate"
  }
}

resource "azurerm_virtual_network" "core_infra" {
  for_each  = var.vnet_info

  name                = each.key
  address_space       = [each.value]
  location            = data.terraform_remote_state.rg.outputs.location
  resource_group_name = data.terraform_remote_state.rg.outputs.rg_name

  tags = {
    env = "${element(split("_",each.key),0)}"
    app = "network"
    owner = "jeewan"
  }
}

resource "azurerm_subnet" "core_infra" {
  for_each = var.subnet_info

  name                 = each.key
  resource_group_name  = data.terraform_remote_state.rg.outputs.rg_name
  virtual_network_name = azurerm_virtual_network.core_infra["${element(split("_",each.key),0)}_vnet"].name
  address_prefixes     = [each.value]
}