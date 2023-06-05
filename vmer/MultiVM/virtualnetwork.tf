resource "azurerm_virtual_network" "fdlab-network" {
  name                = var.network_details.network_name
  location            = local.location
  resource_group_name = local.resource_group_name
  address_space       = [var.network_details.network_address_space]


  subnet {
    name                   = var.network_details.vm_subnet_name
    address_prefix = "10.0.0.0/16"
  }
depends_on = [
  azurerm_resource_group.fdvm-lab01
]

tags = {
    environment = "fdlab01"
  }
}

resource "azurerm_subnet" "fdsubnetlab2"{
    name = "fdsubnetlab2"
     virtual_network_name = var.network_details.network_name
     resource_group_name = local.resource_group_name
     address_prefixes = ["10.0.0.0/16"]
    depends_on = [
      azurerm_virtual_network.fdlab-network,
      local.resource_group_name,
      local.location
    ]
 }


resource "azurerm_network_interface" "fdniclab01" {
  count = 2
  name                = format("fdniclab%s",(count.index)+1)
  location            = local.location
  resource_group_name = local.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.fdsubnetlab2.id
    private_ip_address_allocation = "Dynamic"
 public_ip_address_id = azurerm_public_ip.fdpubiplab02[count.index].id

 }
  depends_on = [
    azurerm_virtual_network.fdlab-network,
    azurerm_public_ip.fdpubiplab02
  ]
}
resource "azurerm_public_ip" "fdpubiplab02" {
  count = 2
  name                    = format("fdpubiplab02%s",(count.index)+1)
  location                = local.location
  resource_group_name     = local.resource_group_name
  allocation_method       = "Static"
  idle_timeout_in_minutes = 30
  depends_on = [
    azurerm_resource_group.fdvm-lab01
  ]

  tags = {
    environment = "fdlab01"
  }
}
