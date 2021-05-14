data "azurerm_virtual_network" "core" {
  name                = "core_infra-vnet"
  resource_group_name = "core"
}

data "azurerm_subnet" "core" {
  name                 = "core_infra-subnet"
  virtual_network_name = data.azurerm_virtual_network.core.name
  resource_group_name  = "core"
}

output "subnet_id" {
  value = data.azurerm_subnet.core.id
}
