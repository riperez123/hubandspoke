########################
# Variables
########################

variable "subscription_id" {
  type        = string
  default     = "default"
  description = "Azure Subscription"
}

variable "client_id" {
  type        = string
  default     = "default"
  description = "Service Principle ID"
}

variable "client_secret" {
  type        = string
  default     = "default"
  description = "description"
}

variable "tenant_id" {
  type        = string
  default     = "default"
  description = "Azure Tenant ID"
}

variable "primary-rg" {
  type        = string
  default     = "default"
  description = "Hub and Spoke RG"
}

variable "primary-location" {
  type        = string
  default     = "default"
  description = "Primary Azure Location"
}

variable "vpngw-shared-key" {
  type        = string
  default     = "default"
  description = "Shared key for VPN connections"
}

variable "vm-user" {
  type        = string
  default     = "default"
  description = "Admin user for VMs"
}

variable "vm-password" {
  type        = string
  default     = "default"
  description = "Password for Vms"
}

variable "vm-size" {
  type        = string
  default     = "default"
  description = "Azure VM size for lab"
}

###########################
# Locals
###########################


locals {
  primary-region-prefix            = "10.1.0.0/16"
  primary-hub-prefix               = ["10.1.0.0/24"]
  primary-hub-gatewaysubnet        = ["10.1.0.0/27"]
  primary-hub-azurebastionsubnet   = ["10.1.0.32/27"]
  primary-hub-azurefirewallsubnet  = ["10.1.0.64/26"]
  primary-hub-vmsubnet             = ["10.1.0.128/27"]
  primary-spoke1-prefix            = ["10.1.1.0/24"]
  primary-spoke1-fesubnet          = ["10.1.1.0/25"]
  primary-spoke1-besubnet          = ["10.1.1.128/25"]
  primary-spoke2-prefix            = ["10.1.2.0/24"]
  primary-spoke2-fesubnet          = ["10.1.2.0/25"]
  primary-spoke2-besubnet          = ["10.1.2.128/25"]
  onprem-site-1-prefix             = ["192.168.1.0/24"]
  onprem-site-1-gatewaysubnet      = ["192.168.1.0/27"]
  onprem-site-1-azurebastionsubnet = ["192.168.1.32/27"]
  onprem-site-1-vmsubnet           = ["192.168.1.64/27"]
  onprem-site-2-prefix             = ["192.168.2.0/24"]
  onprem-site-2-gatewaysubnet      = ["192.168.2.0/27"]
  onprem-site-2-azurebastionsubnet = ["192.168.2.32/27"]
  onprem-site-2-vmsubnet           = ["192.168.2.64/27"]
}