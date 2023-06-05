resource "azurerm_resource_group" "aads" {
  name     = "aads"
  location = "norwayeast"
}


#k#Create KeyVault ID
resource "random_id" "FDV" {
  byte_length = 5
  prefix      = "keyvault"
}
#Keyvault Creation
data "azurerm_client_config" "current" {}
resource "azurerm_key_vault" "FDkv001" {
  #depends_on                  = [azurerm_resource_group.rg.name]
  name                        = "FDvault001"
  location                    = "norwayeast"
  resource_group_name         = azurerm_resource_group.aads.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [

        "Backup"
    ]

    secret_permissions = [
      "Get",
      "Set",
      "Delete",
      "Recover"

    ]

    storage_permissions = [
      "Get"
    ]
  }
}
resource "random_password" "password" {
  length      = 20
  min_lower   = 1
  min_upper   = 1
  min_numeric = 1
  min_special = 1
  special     = true
}

#Create Key Vault Secret
resource "azurerm_key_vault_secret" "admpassword" {
  name         = "admpassword"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.FDkv001.id
  depends_on   = [azurerm_key_vault.FDkv001]
}
