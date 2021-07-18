module data_src {
  source = "../../data-sources/"
}

resource "azurerm_storage_account" "core_storage" {
  name                     = "corestorageaccforlab"
  resource_group_name      = module.data_src.core_rg_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "core_storage" {
  name                  = "terraform-state"
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "core_storage-prod" {
  name                  = "terraform-prod-state"
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}

resource "azurerm_storage_container" "core_storage3-dev" {
  name                  = "terraform-dev-state"
  storage_account_name  = azurerm_storage_account.core_storage.name
  container_access_type = "private"
}