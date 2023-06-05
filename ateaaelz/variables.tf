# Core
variable "root_id" {
  type        = string
  default     = "FD"
  description = "Used for naming ALZ resources"
}

variable "root_name" {
  type        = string
  default     = "ForsvDep"
  description = "Used for naming ALZ resources"
}

variable "default_location" {
  type        = string
  default     = "norwayeast"
  description = "Default location for ALZ resources"
}

variable "decommissioned_subscription_ids" {
  type        = list(string)
  default     = [""]
  description = "Subscription IDs to be placed in Decommissioned management group"
}

# Management
variable "deploy_management_resources" {
  type    = bool
  default = true
}

variable "management_subscription_id" {
  type        = string
  description = "ID for the management subscription"
}

variable "log_retention_in_days" {
  type    = number
  default = 50
}

variable "security_alerts_email_address" {
  type = string
  default = "anne-grethe.knutsen@atea.no"
}

variable "management_resources_location" {
  type    = string
  default = "norwayeast"
}

variable "management_resources_tags" {
  type = map(string)
  default = {
    deployed_by_terraform = true
  }
}