
data "azurerm_client_config" "current" {}


resource "azurerm_key_vault" "fdvault1" {
  name                        = "fdvault1"
  location                    = local.location
  resource_group_name         = local.resource_group_name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days  = 7
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
     "Backup", "Create", "Decrypt" ,"Delete" ,"Encrypt", "Get" ,"Import", "List" ,"Purge" ,"Recover", "Restore"
    ]

    secret_permissions = [
      "Set",
      "Get",
      "Delete",
      "Purge",
      "Recover"
    ]

    storage_permissions = [
      "Get","Set","Purge"
    ]
  }
  depends_on = [
    azurerm_resource_group.fdvm-lab01
  ]
}
# data "azurerm_key_vault_secret" "brukernavn"{
#  name = "hemmelig"
#  key_vault_id = azurerm_key_vault.fdvault1.id
#}

#Create KeyVault VM password
resource "random_password" "vmpassword" {
  length  = 20
  special = true
}
#Create Key Vault Secret
resource "azurerm_key_vault_secret" "vmpassword" {
  name         = "vmpassword"
  value        = random_password.vmpassword.result
  key_vault_id = azurerm_key_vault.fdvault1.id
  depends_on   = [azurerm_key_vault.fdvault1]
}





