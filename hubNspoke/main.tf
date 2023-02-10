#########################################################
# Resource Groups 
#########################################################
resource "azurerm_resource_group" "primary-rg" {
  name     = var.primary-rg
  location = var.primary-location
}

/*resource "azurerm_resource_group" "hubandspoke-secondary-rg" {
  name     = var.secondary-rg
  location = var.secondary-location
}

resource "azurerm_resource_group" "hubandspoke-onprem1-rg" {
  name     = var.onprem-site1-rg
  location = var.primary-location
}

resource "azurerm_resource_group" "hubandspoke-onprem2-rg" {
  name     = var.onprem-site2-rg
  location = var.secondary-location
}*/