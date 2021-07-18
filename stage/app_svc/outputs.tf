  
output "app_service_name" {
  value = [
      for item in azurerm_app_service.app:
      #"${azurerm_app_service.app[app].name}"
      item.name
  ]
  
}

output "app_service_default_hostname" {

  value = [
      for item in azurerm_app_service.app:
      "https://${item.default_site_hostname}"
  ]
  
}