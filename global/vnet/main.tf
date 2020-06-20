terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "terraform-vnet.tfstate"
  }
}

module data_src {
  source = "../../data-sources/"
}

resource "azurerm_virtual_network" "core_infra" {
  name                = "${var.resource_prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = module.data_src.core_rg_name
}

resource "azurerm_subnet" "core_infra" {
  name                 = "${var.resource_prefix}-subnet"
  resource_group_name  = module.data_src.core_rg_name
  virtual_network_name = azurerm_virtual_network.core_infra.name
  address_prefixes     = ["10.0.2.0/24"]
}
