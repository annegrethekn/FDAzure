resource "azurerm_resource_group" "rg" {
  location = "norwayeast"
  name     = "FDVM-rg"
}

# Create virtual network
resource "azurerm_virtual_network" "FD_terraform_vnet" {
  name                = "FD_terraform_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Create subnet
resource "azurerm_subnet" "fd_terraform_subnet" {
  name                 = "fd_terraform_subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.FD_terraform_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
depends_on = [
  azurerm_network_security_group.FD_terraform_nsg
 ]
}


# Create public IPs
resource "azurerm_public_ip" "fd001_terraform_public_ip" {
  name                = "fd001_terraform_public_ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

# Create Network Security Group and rules
resource "azurerm_network_security_group" "FD_terraform_nsg" {
  name                = "FD_terraform_nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "web"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create network interface
resource "azurerm_network_interface" "FD01_terraform_nic" {
  name                = "FD01_terraform_nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "FD01_configuration"
    subnet_id                     = azurerm_subnet.fd_terraform_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.fd001_terraform_public_ip.id
  }
  depends_on = [ azurerm_public_ip.fd001_terraform_public_ip ]
  }

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "FD01" {
  network_interface_id      = azurerm_network_interface.FD01_terraform_nic.id
  network_security_group_id = azurerm_network_security_group.FD_terraform_nsg.id
depends_on = [ azurerm_network_interface.FD01_terraform_nic ]
}


# Create storage account for boot diagnostics
resource "azurerm_storage_account" "FD01storageaccount2" {
  name                     = "fd01storageaccount2"
  location                 = azurerm_resource_group.rg.location
  resource_group_name      = azurerm_resource_group.rg.name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  depends_on = [
    azurerm_resource_group.rg

   ]
}


# Create virtual machine
resource "azurerm_windows_virtual_machine" "main" {
  name                  = "fdvm01-vm"
  admin_username        = "azureuser"
  admin_password        = random_password.password.result
  location              = azurerm_resource_group.rg.location
  resource_group_name   = azurerm_resource_group.rg.name
  network_interface_ids = [azurerm_network_interface.FD01_terraform_nic.id]
  size                  = "Standard_DS1_v2"

  os_disk {
    name                 = "myOsDisk"
    caching              = "ReadOnly"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }


  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.FD01storageaccount2.primary_blob_endpoint
  }
}

# Install IIS web server to the virtual machine

# Generate random text for a unique storage account name
resource "random_id" "random_id" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = azurerm_resource_group.rg.name
  }

  byte_length = 8
}

resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

