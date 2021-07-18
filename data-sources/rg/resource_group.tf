data "azurerm_resource_group" "coreinfra" {
  name = "core"
}

output "core_rg_name" {
  value = data.azurerm_resource_group.coreinfra.name
}
