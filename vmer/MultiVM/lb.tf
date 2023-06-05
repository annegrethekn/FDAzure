
resource "azurerm_public_ip" "fdload_ip" {
  name                = "fdload_ip"
  resource_group_name = local.resource_group_name
  location            = local.location
  allocation_method   = "Static"
  sku = "Standard"

  tags = {
    environment = "fdlab01"
  }
  depends_on = [
    azurerm_resource_group.fdvm-lab01
  ]
}
resource "azurerm_lb" "fdlbloadbalancer01" {
  name                = "fdlbloadbalancer01"
  sku = "Standard"
  location            = local.location
  resource_group_name = local.resource_group_name

  frontend_ip_configuration {
    name                 = "fdfrontend_ip"
    public_ip_address_id = azurerm_public_ip.fdload_ip.id
  }
  depends_on = [
    azurerm_public_ip.fdload_ip,
    azurerm_resource_group.fdvm-lab01
  ]
}

resource "azurerm_lb_backend_address_pool" "scalesetpool" {
   loadbalancer_id = azurerm_lb.fdlbloadbalancer01.id
   name            = "scalesetpool"
   depends_on = [
    azurerm_lb.fdlbloadbalancer01,
    azurerm_resource_group.fdvm-lab01,
     ]
}

resource "azurerm_lb_backend_address_pool_address" "fdvm1_address" {
  name                                = "fdvm1_address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.scalesetpool.id
  #backend_address_ip_configuration_id = azurerm_public_ip.fdload_ip.id
  virtual_network_id = azurerm_virtual_network.fdlab-network.id
  ip_address = azurerm_network_interface.fdniclab01[0].private_ip_address
  depends_on = [
    azurerm_lb_backend_address_pool_address.fdvm1_address,
   azurerm_resource_group.fdvm-lab01,
    azurerm_virtual_network.fdlab-network
  ]
}

resource "azurerm_lb_backend_address_pool_address" "fdvm2_address" {
  name                                = "fdvm2_address"
  backend_address_pool_id             = azurerm_lb_backend_address_pool.scalesetpool.id
 # backend_address_ip_configuration_id = azurerm_public_ip.fdload_ip.id
  virtual_network_id = azurerm_virtual_network.fdlab-network.id
  ip_address =  azurerm_network_interface.fdniclab01[1].private_ip_address
  depends_on = [
    azurerm_lb_backend_address_pool.scalesetpool,
    azurerm_lb_backend_address_pool.scalesetpool
  ]
}
resource "azurerm_lb_probe" "fdprobelab01" {
  loadbalancer_id = azurerm_lb.fdlbloadbalancer01.id
  name            = "fdprobelab01"
  port            = 80
}
resource "azurerm_lb_rule" "fdlbrulelab01" {
  loadbalancer_id                = azurerm_lb.fdlbloadbalancer01.id
  name                           = "fdlbrulelab01"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "fdfrontend_ip"
  probe_id = azurerm_lb_probe.fdprobelab01.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.scalesetpool.id]
}
