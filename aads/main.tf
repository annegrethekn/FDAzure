

resource "azurerm_virtual_network" "aads" {
  name                = "aads-vnet"
  location            = azurerm_resource_group.aads.location
  resource_group_name = azurerm_resource_group.aads.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aads" {
  name                 = "aads-subnet"
  resource_group_name  = azurerm_resource_group.aads.name
  virtual_network_name = azurerm_virtual_network.aads.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_network_security_group" "aads" {
  name                = "aads-nsg"
  location            = azurerm_resource_group.aads.location
  resource_group_name = azurerm_resource_group.aads.name

  security_rule {
    name                       = "AllowSyncWithAzureAD"
    priority                   = 101
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowRD"
    priority                   = 201
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "CorpNetSaw"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowPSRemoting"
    priority                   = 301
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5986"
    source_address_prefix      = "AzureActiveDirectoryDomainServices"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowLDAPS"
    priority                   = 401
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "636"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "aads" {
  subnet_id                 = azurerm_subnet.aads.id
  network_security_group_id = azurerm_network_security_group.aads.id
}

resource "azuread_group" "dc_admins" {
  display_name     = "AAD DC Administrators"
  security_enabled = true
}

resource "azuread_user" "domadmin" {
  user_principal_name = "domadmin@s5lab.no"
  display_name        = "DCDomene Administrator"
  password            = azurerm_key_vault_secret.admpassword.value
}

resource "azuread_group_member" "admin" {
  group_object_id  = azuread_group.dc_admins.object_id
  member_object_id = azuread_user.domadmin.object_id
}

resource "azuread_service_principal" "AADDservice" {
   application_id = "2565bd9d-da50-47d4-8b85-4c97f669dc36" // published app for domain services
}

resource "azurerm_resource_group" "aadds" {
  name     = "aadds-rg"
  location = "norwayeast"
}

resource "azurerm_active_directory_domain_service" "fddaads" {
  name                = "fddaads"
  location            = azurerm_resource_group.aadds.location
  resource_group_name = azurerm_resource_group.aadds.name

  domain_name           = "s5lab.no"
  sku                   = "Standard"
  filtered_sync_enabled = false

  initial_replica_set {
    subnet_id = azurerm_subnet.aads.id
  }

  notifications {
    additional_recipients = ["anne-grethe.knutsen@atea.no", "notifyB@example.org"]
    notify_dc_admins      = true
    notify_global_admins  = true
  }

  security {
    sync_kerberos_passwords = true
    sync_ntlm_passwords     = true
    sync_on_prem_passwords  = true
  }

  tags = {
    Environment = "lab"
  }

  depends_on = [
   azuread_service_principal.AADDservice,
    azurerm_subnet_network_security_group_association.aads,

  ]
}