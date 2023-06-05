resource "azurerm_network_security_group" "fdnsglab01" {
  name                = "fdnsglab01"
  location            = local.location
  resource_group_name = local.resource_group_name
   depends_on = [
   local.resource_group_name
  ]

  security_rule {
    name                       = "AllowRDP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges     = ["3389","80","8080", "443"]
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }


  tags = {
    environment = "fdlab01"
  }
}
resource "azurerm_subnet_network_security_group_association" "fdnsgas" {
  subnet_id                 = azurerm_subnet.fdsubnetlab2.id
  network_security_group_id = azurerm_network_security_group.fdnsglab01.id
  depends_on = [
    azurerm_network_security_group.fdnsglab01
  ]
}