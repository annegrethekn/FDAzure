variable "resource_group_name" {
  description = "The name of the resource group"
  default = "FDVM-rg"
}

#variable "subnet_id" {
#  description = "Subnet ID for the Domain Controllers"
#  default = fd_terraform_subnet.id
#}

variable "active_directory_domain_name" {
  description = "the domain name for Active Directory"
  default = "fdtest365.onmicrosoft.com"
 }

variable "admin_username" {
  description = "Username for the Domain Administrator user"
  default = "azureuser"
}

variable "admin_password" {
  description = "Password for the Adminstrator user"
  default = "FDdomvault.LokaBruker.value"
}

variable "active_directory_username" {
  description = "The username of an account with permissions to bind machines to the Active Directory Domain"
  default ="DevOps@fdtest365.onmicrosoft.com"
}

variable "active_directory_password" {
  description = "The password of the account with permissions to bind machines to the Active Directory Domain"
default = "FDdomvault.DomeneBruker.value"
}

locals {
  virtual_machine_name = join("-",[azurerm_windows_virtual_machine.main.name])
  wait_for_domain_command = "while (!(Test-Connection -TargetName ${var.active_directory_domain_name} -Count 1 -Quiet) -and ($retryCount++ -le 360)) { Start-Sleep 10 }"
}