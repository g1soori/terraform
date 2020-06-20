terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    key                   = "terraform-core-rg.tfstate"
  }
}

resource "azurerm_resource_group" "core_infra" {
  name     = var.resource_grp
  location = var.location
}
