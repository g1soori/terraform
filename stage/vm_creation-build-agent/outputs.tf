output "ip" {
  value = azurerm_linux_virtual_machine.ansible.private_ip_address
}

output "pubip" {
  value = azurerm_linux_virtual_machine.ansible.public_ip_address
}