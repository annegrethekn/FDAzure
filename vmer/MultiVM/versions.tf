terraform {
  required_providers {
    azurerm ={
      source = "hashicorp/azurerm"
      version = "3.56.0"
    }
  }
}
provider "azurerm" {
subscription_id = "9331a504-ee29-4876-9c59-a57c785ff33c"
 client_id       = "0c59b34a-fdc2-4259-ab9a-66a6502949a3"
 client_secret   = "kLT8Q~rqVrrl9WDqbkxm87Y3qFUIzhaDODXqUc_R"
tenant_id       = "74132921-020d-4de6-85c1-ce557f0654f5"

features {
  key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = false
    }
 }
 }