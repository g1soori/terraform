output vnet_name {
  value       = {
      for vnet in azurerm_virtual_network.core_infra:
      "${element(split("_",vnet.name),0)}" => vnet.name
  }
  description = "expose vnet names"
  depends_on  = []
}

output subnet_id {
  value       = {
      for subnet in azurerm_subnet.core_infra:
      "${element(split("_",subnet.name),0)}" => subnet.id
  }
  description = "expose subnet ids"
  depends_on  = []
}