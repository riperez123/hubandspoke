#########################################################
# Resource Groups 
#########################################################
resource "azurerm_resource_group" "primary-rg" {
  name     = var.primary-rg
  location = var.primary-location
}

