terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
subscription_id = "9331a504-ee29-4876-9c59-a57c785ff33c"
 client_id       = "0c59b34a-fdc2-4259-ab9a-66a6502949a3"
 client_secret   = "3zO8Q~6K~SsNmlKpOHw7et_JpVqQTCrhzCcyxbY~"
 tenant_id       = "74132921-020d-4de6-85c1-ce557f0654f5"
  features {}
}
