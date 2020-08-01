
# module "core_modules" {
#   source = "../../data-sources/"
# }

terraform {
  backend "azurerm" {
    resource_group_name   = "core"
    storage_account_name  = "corestorageaccforlab"
    container_name        = "terraform-state"
    #key                   = "terraform-acr-new.tfstate"
    key                   = "terraform-imagegallery.tfstate"
  }
}

resource "azurerm_container_registry" "containerreg" {
  name                     = "g1sooricontainerreg"
  resource_group_name      = var.resource_grp
  location                 = var.location
  sku                      = "Basic"
#  storage_account_id       = module.core_modules.storage_account_id
  admin_enabled            = true
}