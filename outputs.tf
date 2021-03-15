output "m_az_public_ip" {
  value = azurerm_public_ip.auchan_public_ip.ip_address
} 
output "m_az_private_ip_address" {
    value = azurerm_network_interface.auchan-nic.ip_configuration[0].private_ip_address
}