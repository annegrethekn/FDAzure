resource "azurerm_resource_group" "VirtualMachines" {
  name = "VirtualMachines"
  location = "norwayeast"
}



resource "azurerm_resource_group" "fdvm-lab01" {
  name     = "fdvm-lab01"
  location = "norwayeast"
}

locals {
  resource_group_name = "fdvm-lab01"
  location            =  "norwayeast"
  }