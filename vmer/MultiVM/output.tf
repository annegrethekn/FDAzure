output "private_ip_address" {
  description = "Intern ip adresse på vm"
  value={
    for ip in azurerm_network_interface.fdniclab01:
    ip.name=>ip.private_ip_address
  }
}