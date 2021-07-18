output "instance_ip_addr" {
  #count = var.server_count

  value       = azurerm_linux_virtual_machine.ansible[1].private_ip_address 
  description = "The private IP address of the main server instance."
}