output rg_name {
  value       = azurerm_resource_group.core_infra.name
  description = "resource group name"
}

output location {
  value       = azurerm_resource_group.core_infra.location
  description = "resource group name"
}
